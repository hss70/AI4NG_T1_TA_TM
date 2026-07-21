#!/bin/bash
set -Eeuo pipefail

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

# Timing variables for benchmark.json
TIMING_MKDIRS_MS=""
TIMING_COPY_DEPENDENTS_MS=""
TIMING_S3_DOWNLOAD_INPUT_MS=""
TIMING_UNZIP_INPUT_MS=""
TIMING_METADATA_PARSE_AND_EXPORT_MS=""
TIMING_S3_UPLOAD_METADATA_MS=""
TIMING_MATLAB_TOTAL_MS=""
TIMING_COPY_OUTPUT_FILES_MS=""
TIMING_S3_UPLOAD_RESULTS_MS=""
TIMING_S3_UPLOAD_BENCHMARK_MS=""
TIMING_SCRIPT_TOTAL_MS=""

RUN_STATUS="FAILED"
FAILURE_REASON=""
EXIT_CODE=1
MATLAB_EXIT_CODE=""
MATLAB_STARTED_EPOCH=""
MATLAB_ENDED_EPOCH=""
RESULTS_PATH=""
ACTUAL_CORES=""
BENCHMARK_JSON="/app/output/benchmark.json"

run_timed() {
  local step="$1"
  local timing_var="$2"
  shift 2

  local start_ms end_ms elapsed_ms

  log "START step=${step}"
  start_ms=$(now_ms)
  "$@"
  end_ms=$(now_ms)
  elapsed_ms=$((end_ms - start_ms))
  log "END step=${step}"
  log_timing "$step" "$elapsed_ms"
  printf -v "$timing_var" '%s' "$elapsed_ms"
}

write_benchmark_json() {
  [[ "${BENCHMARK_MODE:-0}" == "1" ]] || return 0

  mkdir -p /app/output

  ACTUAL_CORES="${ACTUAL_CORES:-$(nproc 2>/dev/null || echo "")}"

  jq -n \
    --arg benchmarkId "${BENCHMARK_ID:-}" \
    --arg label "${BENCHMARK_LABEL:-}" \
    --argjson runNumber "${BENCHMARK_RUN_NUMBER:-0}" \
    --arg userId "${USER_ID:-}" \
    --arg sessionName "${SESSION_NAME:-}" \
    --arg sessionId "${SESSION_ID_CLEAN:-}" \
    --arg inputFile "${INPUT_FILE:-}" \
    --arg resultsBucket "${RESULTS_BUCKET:-}" \
    --arg resultsPath "${RESULTS_PATH:-}" \
    --arg benchmarkOutputKey "${BENCHMARK_OUTPUT_KEY:-}" \
    --arg parallelEnabled "${PARALLEL_ENABLED:-}" \
    --arg parallelWorkersRequested "${PARALLEL_WORKERS:-}" \
    --arg parallelProfileFile "${PARALLEL_PROFILE_FILE:-}" \
    --arg taskCpu "${BENCHMARK_TASK_CPU:-}" \
    --arg taskMemory "${BENCHMARK_TASK_MEMORY:-}" \
    --arg availableCores "${ACTUAL_CORES:-}" \
    --arg status "${RUN_STATUS:-FAILED}" \
    --arg failureReason "${FAILURE_REASON:-}" \
    --argjson exitCode "${EXIT_CODE:-1}" \
    --argjson matlabExitCode "${MATLAB_EXIT_CODE:-0}" \
    --argjson matlabStartEpoch "${MATLAB_STARTED_EPOCH:-0}" \
    --argjson matlabEndEpoch "${MATLAB_ENDED_EPOCH:-0}" \
    --arg timestamp "$(ts)" \
    --argjson mkdirsMs "${TIMING_MKDIRS_MS:-0}" \
    --argjson copyDependentsMs "${TIMING_COPY_DEPENDENTS_MS:-0}" \
    --argjson s3DownloadInputMs "${TIMING_S3_DOWNLOAD_INPUT_MS:-0}" \
    --argjson unzipInputMs "${TIMING_UNZIP_INPUT_MS:-0}" \
    --argjson metadataParseAndExportMs "${TIMING_METADATA_PARSE_AND_EXPORT_MS:-0}" \
    --argjson s3UploadMetadataMs "${TIMING_S3_UPLOAD_METADATA_MS:-0}" \
    --argjson matlabTotalMs "${TIMING_MATLAB_TOTAL_MS:-0}" \
    --argjson copyOutputFilesMs "${TIMING_COPY_OUTPUT_FILES_MS:-0}" \
    --argjson s3UploadResultsMs "${TIMING_S3_UPLOAD_RESULTS_MS:-0}" \
    --argjson s3UploadBenchmarkMs "${TIMING_S3_UPLOAD_BENCHMARK_MS:-0}" \
    --argjson scriptTotalMs "${TIMING_SCRIPT_TOTAL_MS:-0}" \
    '
    {
      benchmarkId: $benchmarkId,
      label: $label,
      runNumber: $runNumber,
      timestampUtc: $timestamp,
      status: $status,
      failureReason: (if $failureReason == "" then null else $failureReason end),

      session: {
        userId: $userId,
        sessionName: $sessionName,
        sessionId: $sessionId,
        inputFile: $inputFile,
        resultsBucket: $resultsBucket,
        resultsPath: $resultsPath,
        benchmarkOutputKey: $benchmarkOutputKey
      },

      config: {
        parallelEnabled: $parallelEnabled,
        parallelWorkersRequested: $parallelWorkersRequested,
        parallelProfileFile: $parallelProfileFile,
        taskCpu: $taskCpu,
        taskMemory: $taskMemory,
        availableCores: $availableCores
      },

      execution: {
        exitCode: $exitCode,
        matlabExitCode: $matlabExitCode,
        matlabStartEpoch: $matlabStartEpoch,
        matlabEndEpoch: $matlabEndEpoch
      },

      timingsMs: {
        mkdirs: $mkdirsMs,
        copyDependents: $copyDependentsMs,
        s3DownloadInput: $s3DownloadInputMs,
        unzipInput: $unzipInputMs,
        metadataParseAndExport: $metadataParseAndExportMs,
        s3UploadMetadata: $s3UploadMetadataMs,
        matlabTotal: $matlabTotalMs,
        copyOutputFiles: $copyOutputFilesMs,
        s3UploadResults: $s3UploadResultsMs,
        s3UploadBenchmark: $s3UploadBenchmarkMs,
        scriptTotal: $scriptTotalMs
      }
    }
    ' > "$BENCHMARK_JSON"
}

upload_benchmark_json() {
  [[ "${BENCHMARK_MODE:-0}" == "1" ]] || return 0
  [[ -n "${BENCHMARK_OUTPUT_KEY:-}" ]] || return 0
  [[ -f "$BENCHMARK_JSON" ]] || return 0

  local start_ms end_ms elapsed_ms
  log "START step=s3_upload_benchmark"
  start_ms=$(now_ms)

  aws s3 cp "$BENCHMARK_JSON" "s3://${RESULTS_BUCKET}/${BENCHMARK_OUTPUT_KEY}"

  end_ms=$(now_ms)
  elapsed_ms=$((end_ms - start_ms))
  TIMING_S3_UPLOAD_BENCHMARK_MS="$elapsed_ms"
  log "END step=s3_upload_benchmark"
  log_timing "s3_upload_benchmark" "$elapsed_ms"
}

finalize() {
  local final_exit_code=$?
  EXIT_CODE=$final_exit_code

  if [[ $final_exit_code -eq 0 ]]; then
    RUN_STATUS="SUCCESS"
  else
    RUN_STATUS="FAILED"
  fi

  local script_end_ms
  script_end_ms=$(now_ms)
  TIMING_SCRIPT_TOTAL_MS=$((script_end_ms - script_start_ms))
  log_timing "script_total" "$TIMING_SCRIPT_TOTAL_MS"

  # Write benchmark file on both success and failure
  write_benchmark_json

  # Try to upload benchmark file even if main flow failed
  if ! upload_benchmark_json; then
    log "WARNING: benchmark upload failed"
  fi

  exit "$final_exit_code"
}

on_error() {
  local line_no=$1
  local exit_code=$2
  FAILURE_REASON="Script failed at line ${line_no}"
  log "ERROR: ${FAILURE_REASON} (exitCode=${exit_code})"
  exit "$exit_code"
}

trap 'on_error $LINENO $?' ERR
trap finalize EXIT

log "Starting EEG processing for session ${SESSION_ID_CLEAN}"

export WORK_DIR="/app/work"
export HOME_DIR="$WORK_DIR"
export WORK_PATH="$WORK_DIR/Work"
export OUTPUT_DIR="$WORK_DIR/Results"
export PARALLEL_ENABLED="${PARALLEL_ENABLED:-1}"
export PARALLEL_WORKERS="${PARALLEL_WORKERS:-2}"
export PARALLEL_PROFILE_FILE="${PARALLEL_PROFILE_FILE:-}"
export BENCHMARK_MODE="${BENCHMARK_MODE:-0}"
export BENCHMARK_ID="${BENCHMARK_ID:-}"
export BENCHMARK_LABEL="${BENCHMARK_LABEL:-}"
export BENCHMARK_RUN_NUMBER="${BENCHMARK_RUN_NUMBER:-}"
export BENCHMARK_OUTPUT_KEY="${BENCHMARK_OUTPUT_KEY:-}"
export BENCHMARK_TASK_CPU="${BENCHMARK_TASK_CPU:-}"
export BENCHMARK_TASK_MEMORY="${BENCHMARK_TASK_MEMORY:-}"

ACTUAL_CORES_NPROC=$(nproc 2>/dev/null || echo "")
CPUINFO_COUNT=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "")
log "Parallel diag: requestedWorkers=${PARALLEL_WORKERS}, nproc=${ACTUAL_CORES_NPROC}, cpuinfo=${CPUINFO_COUNT}, benchmarkCpu=${BENCHMARK_TASK_CPU}, benchmarkMemory=${BENCHMARK_TASK_MEMORY}"

run_timed "mkdirs" "TIMING_MKDIRS_MS" mkdir -p \
  "$WORK_DIR/Dependents" \
  "$WORK_PATH/CSV/$USER_ID/$SESSION_NAME" \
  "$WORK_PATH/Results" \
  "/app/output"

run_timed "copy_dependents" "TIMING_COPY_DEPENDENTS_MS" \
  cp /app/Standard-10-20-Cap81.locs "$WORK_DIR/Dependents/"

log "Downloading $INPUT_FILE from $UPLOAD_BUCKET"
run_timed "s3_download_input" "TIMING_S3_DOWNLOAD_INPUT_MS" \
  aws s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip

log "Unzipping input file to $WORK_PATH/CSV/$USER_ID/$SESSION_NAME"
run_timed "unzip_input" "TIMING_UNZIP_INPUT_MS" \
  unzip -o /app/input.zip -d "$WORK_PATH/CSV/$USER_ID/$SESSION_NAME"

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
  TIMING_METADATA_PARSE_AND_EXPORT_MS=$((metadata_end_ms - metadata_start_ms))
  log_timing "metadata_parse_and_export" "$TIMING_METADATA_PARSE_AND_EXPORT_MS"

  run_timed "s3_upload_metadata" "TIMING_S3_UPLOAD_METADATA_MS" \
    aws s3 cp "$METADATA_FILE" "s3://$RESULTS_BUCKET/$RESULTS_PATH/metadata.json"
else
  FAILURE_REASON="metadata.json not found in input ZIP"
  log "ERROR: $FAILURE_REASON"
  exit 1
fi

export LD_LIBRARY_PATH="/opt/matlabruntime/R2024b/runtime/glnxa64:/opt/matlabruntime/R2024b/bin/glnxa64:/opt/matlabruntime/R2024b/sys/os/glnxa64:/opt/matlabruntime/R2024b/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2024b/extern/bin/glnxa64:${LD_LIBRARY_PATH:-}"

log "Running MATLAB executable"
MATLAB_STARTED_EPOCH=$(date +%s)
matlab_start_ms=$(now_ms)

./run_FBCSP_Training.sh "${MATLAB_RUNTIME_ROOT:-/opt/matlabruntime/R2024b}" 2>&1 | while IFS= read -r line; do
  echo "[SESSION_ID=${SESSION_ID_CLEAN}] $(ts) MATLAB $line"
done
MATLAB_EXIT_CODE=${PIPESTATUS[0]}
EXIT_CODE=$MATLAB_EXIT_CODE

matlab_end_ms=$(now_ms)
MATLAB_ENDED_EPOCH=$(date +%s)
TIMING_MATLAB_TOTAL_MS=$((matlab_end_ms - matlab_start_ms))
log_timing "matlab_total" "$TIMING_MATLAB_TOTAL_MS"

if [[ $MATLAB_EXIT_CODE -ne 0 ]]; then
  FAILURE_REASON="MATLAB execution failed with exit code $MATLAB_EXIT_CODE"
  log "ERROR: $FAILURE_REASON"
  exit "$MATLAB_EXIT_CODE"
fi

MANIFEST="/app/output/manifest.json"

copy_output_start_ms=$(now_ms)
cp -r "$OUTPUT_DIR"/* /app/output/ 2>/dev/null || true
copy_output_end_ms=$(now_ms)
TIMING_COPY_OUTPUT_FILES_MS=$((copy_output_end_ms - copy_output_start_ms))
log_timing "copy_output_files" "$TIMING_COPY_OUTPUT_FILES_MS"

jq -n \
  --arg userId "$USER_ID" \
  --arg sessionName "$SESSION_NAME" \
  --arg sessionId "$SESSION_ID_CLEAN" \
  --arg inputFile "$INPUT_FILE" \
  --argjson startTime "$MATLAB_STARTED_EPOCH" \
  --argjson endTime "$MATLAB_ENDED_EPOCH" \
  --arg resultsPath "$RESULTS_PATH" \
  --argjson exitCode "$MATLAB_EXIT_CODE" \
  --argjson outputFiles "$(find /app/output -type f -printf '%P\n' | jq -R . | jq -s .)" \
  '
  {
    userId: $userId,
    sessionName: $sessionName,
    sessionId: $sessionId,
    inputFile: $inputFile,
    startTime: $startTime,
    endTime: $endTime,
    resultsPath: $resultsPath,
    exitCode: $exitCode,
    outputFiles: $outputFiles
  }
  ' > "$MANIFEST"

log "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/"
run_timed "s3_upload_results" "TIMING_S3_UPLOAD_RESULTS_MS" \
  aws s3 cp /app/output/ "s3://$RESULTS_BUCKET/$RESULTS_PATH/" --recursive

echo '{"resultsPath": "'"$RESULTS_PATH"'"}'