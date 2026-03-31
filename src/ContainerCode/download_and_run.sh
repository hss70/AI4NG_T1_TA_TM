#!/bin/bash
set -euo pipefail

script_start_ms=$(python3 - <<'PY'
import time
print(int(time.perf_counter() * 1000))
PY
)

ts() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

now_ms() {
  python3 - <<'PY'
import time
print(int(time.perf_counter() * 1000))
PY
}

SESSION_ID_CLEAN=${SESSION_ID//\"/}

log() {
  local message="$1"
  echo "[SESSION_ID=${SESSION_ID_CLEAN}] $(ts) $message"
}

log_timing() {
  local step="$1"
  local elapsed_ms="$2"
  echo "[SESSION_ID=${SESSION_ID_CLEAN}] $(ts) TIMING step=${step} elapsedMs=${elapsed_ms}"
}

run_timed() {
  local step="$1"
  shift
  local start_ms end_ms elapsed_ms

  log "START step=${step}"
  start_ms=$(now_ms)
  "$@"
  end_ms=$(now_ms)
  elapsed_ms=$((end_ms - start_ms))
  log "END step=${step}"
  log_timing "$step" "$elapsed_ms"
}

log "Starting EEG processing for session ${SESSION_ID_CLEAN}"

export WORK_DIR="/app/work"
export HOME_DIR="$WORK_DIR"
export WORK_PATH="$WORK_DIR/Work"
export OUTPUT_DIR="$WORK_DIR/Results"
export PARALLEL_ENABLED="${PARALLEL_ENABLED:-0}"
export PARALLEL_WORKERS="${PARALLEL_WORKERS:-2}"
export PARALLEL_PROFILE_FILE="${PARALLEL_PROFILE_FILE:-}"

log "Parallel configuration enabled=${PARALLEL_ENABLED} workers=${PARALLEL_WORKERS} profile=${PARALLEL_PROFILE_FILE:-'(unset)'}"

run_timed "mkdirs" mkdir -p \
  "$WORK_DIR/Dependents" \
  "$WORK_PATH/CSV/$USER_ID/$SESSION_NAME" \
  "$WORK_PATH/Results" \
  "/app/output"

run_timed "copy_dependents" cp /app/Standard-10-20-Cap81.locs "$WORK_DIR/Dependents/"

log "Downloading $INPUT_FILE from $UPLOAD_BUCKET"
run_timed "s3_download_input" aws s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip

log "Unzipping input file to $WORK_PATH/CSV/$USER_ID/$SESSION_NAME"
run_timed "unzip_input" unzip -o /app/input.zip -d "$WORK_PATH/CSV/$USER_ID/$SESSION_NAME"

RESULTS_PATH="$USER_ID/$SESSION_NAME"

METADATA_FILE="$WORK_PATH/CSV/$USER_ID/$SESSION_NAME/metadata.json"
if [[ -f "$METADATA_FILE" ]]; then
    log "Loading metadata from $METADATA_FILE"
    metadata_start_ms=$(now_ms)

    export EEGChannels=$(jq -r '.EEGChannels' "$METADATA_FILE")
    export Frequency=$(jq -r '.Frequency' "$METADATA_FILE")
    export channelNum="$EEGChannels"
    export sampleRate="$Frequency"
    export downSampleRate="$Frequency"

    while IFS="=" read -r key value; do
        key="${key//[^a-zA-Z0-9_]/_}"
        if [[ ! $key =~ ^(USER_ID|SESSION_NAME|INPUT_FILE|UPLOAD_BUCKET|RESULTS_BUCKET)$ ]]; then
            export "$key"="$value"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value | tostring)"' "$METADATA_FILE")

    metadata_end_ms=$(now_ms)
    log_timing "metadata_parse_and_export" "$((metadata_end_ms - metadata_start_ms))"

    run_timed "s3_upload_metadata" aws s3 cp "$METADATA_FILE" "s3://$RESULTS_BUCKET/$RESULTS_PATH/metadata.json"
else
    log "ERROR: metadata.json not found in input ZIP"
    exit 1
fi

export LD_LIBRARY_PATH="/opt/matlabruntime/R2024b/runtime/glnxa64:/opt/matlabruntime/R2024b/bin/glnxa64:/opt/matlabruntime/R2024b/sys/os/glnxa64:/opt/matlabruntime/R2024b/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2024b/extern/bin/glnxa64:${LD_LIBRARY_PATH:-}"

log "Running MATLAB executable"
matlab_start_epoch=$(date +%s)
matlab_start_ms=$(now_ms)

./run_FBCSP_Training.sh "${MATLAB_RUNTIME_ROOT:-/opt/matlabruntime/R2024b}" 2>&1 | while IFS= read -r line; do
    echo "[SESSION_ID=${SESSION_ID_CLEAN}] $(ts) MATLAB $line"
done
EXIT_CODE=${PIPESTATUS[0]}

matlab_end_ms=$(now_ms)
matlab_end_epoch=$(date +%s)
log_timing "matlab_total" "$((matlab_end_ms - matlab_start_ms))"

if [[ $EXIT_CODE -ne 0 ]]; then
    log "ERROR: MATLAB execution failed with exit code $EXIT_CODE"
    exit $EXIT_CODE
fi

MANIFEST="/app/output/manifest.json"
echo '{' > "$MANIFEST"
echo '  "userId": "'"$USER_ID"'",' >> "$MANIFEST"
echo '  "sessionName": "'"$SESSION_NAME"'",' >> "$MANIFEST"
echo '  "sessionId": "'"$SESSION_ID_CLEAN"'",' >> "$MANIFEST"
echo '  "inputFile": "'"$INPUT_FILE"'",' >> "$MANIFEST"
echo '  "startTime": '"$matlab_start_epoch"',' >> "$MANIFEST"
echo '  "endTime": '"$matlab_end_epoch"',' >> "$MANIFEST"
echo '  "resultsPath": "'"$RESULTS_PATH"'",' >> "$MANIFEST"
echo '  "exitCode": '"$EXIT_CODE"',' >> "$MANIFEST"
echo '  "outputFiles": [' >> "$MANIFEST"

copy_output_start_ms=$(now_ms)
cp -r "$OUTPUT_DIR"/* /app/output/ 2>/dev/null || true
copy_output_end_ms=$(now_ms)
log_timing "copy_output_files" "$((copy_output_end_ms - copy_output_start_ms))"

first_file=true
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        if [ "$first_file" = false ]; then
            echo ',' >> "$MANIFEST"
        fi
        relative_path="${file#/app/output/}"
        echo -n '    "'"$relative_path"'"' >> "$MANIFEST"
        first_file=false
    fi
done < <(find /app/output -type f -print0 2>/dev/null)

echo '' >> "$MANIFEST"
echo '  ]' >> "$MANIFEST"
echo '}' >> "$MANIFEST"

log "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/"
run_timed "s3_upload_results" aws s3 cp /app/output/ "s3://$RESULTS_BUCKET/$RESULTS_PATH/" --recursive

script_end_ms=$(now_ms)
log_timing "script_total" "$((script_end_ms - script_start_ms))"

echo '{"resultsPath": "'"$RESULTS_PATH"'"}'
