#!/bin/bash
set -euo pipefail

ts() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log() {
  echo "[LOCAL] $(ts) $1"
}

# Fixed working paths
export WORK_DIR="/app/work"
export HOME_DIR="$WORK_DIR"
export WORK_PATH="$WORK_DIR/Work"
export OUTPUT_DIR="$WORK_DIR/Results"

# Parallel/runtime env defaults
export PARALLEL_ENABLED="${PARALLEL_ENABLED:-1}"
export PARALLEL_WORKERS="${PARALLEL_WORKERS:-2}"
export PARALLEL_PROFILE_FILE="${PARALLEL_PROFILE_FILE:-}"
export MCR_CACHE_ROOT="${MCR_CACHE_ROOT:-/tmp/mcr-cache}"
export MATLAB_PREFDIR="${MATLAB_PREFDIR:-/tmp/matlab-prefs}"

log "Parallel configuration enabled=${PARALLEL_ENABLED} workers=${PARALLEL_WORKERS} profile=${PARALLEL_PROFILE_FILE:-'(unset)'}"

# Create required directories
mkdir -p \
  "$WORK_DIR/Dependents" \
  "$WORK_PATH/CSV/$USER_ID/$SESSION_ID" \
  "$WORK_PATH/Results" \
  "/app/output" \
  "$MCR_CACHE_ROOT" \
  "$MATLAB_PREFDIR"

# Copy the EEG channel locations file to Dependents
cp /app/Standard-10-20-Cap81.locs "$WORK_DIR/Dependents/"

# Download/copy input data
if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
  log "Using custom S3 endpoint: $AWS_ENDPOINT_URL"
  aws_opts="--endpoint-url=$AWS_ENDPOINT_URL"
  log "Downloading $INPUT_FILE from $UPLOAD_BUCKET using custom endpoint"
  aws $aws_opts s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip
elif [[ -d "/test_data" ]]; then
  log "LOCAL TEST MODE: Using mounted test data"
  cp /test_data/test_data.zip /app/input.zip
else
  log "Downloading $INPUT_FILE from $UPLOAD_BUCKET"
  aws s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip
fi

# Unzip into session directory
log "Unzipping input file to $WORK_PATH/CSV/$USER_ID/$SESSION_ID"
unzip -o /app/input.zip -d "$WORK_PATH/CSV/$USER_ID/$SESSION_ID"

# Load metadata and set critical variables
METADATA_FILE="$WORK_PATH/CSV/$USER_ID/$SESSION_ID/metadata.json"
if [[ -f "$METADATA_FILE" ]]; then
    log "Loading metadata from $METADATA_FILE"

    export EEGChannels=$(jq -r '.EEGChannels' "$METADATA_FILE")
    export Frequency=$(jq -r '.Frequency' "$METADATA_FILE")

    export channelNum="$EEGChannels"
    export sampleRate="$Frequency"
    export downSampleRate="$Frequency"

    while IFS="=" read -r key value; do
        key="${key//[^a-zA-Z0-9_]/_}"
        if [[ ! $key =~ ^(USER_ID|SESSION_ID|INPUT_FILE|UPLOAD_BUCKET|RESULTS_BUCKET)$ ]]; then
            export "$key"="$value"
            log "Set env: $key=$value"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value | tostring)"' "$METADATA_FILE")
else
    log "ERROR: metadata.json not found in input ZIP"
    exit 1
fi

# Set MATLAB Runtime library path
export LD_LIBRARY_PATH="/opt/matlabruntime/R2024b/runtime/glnxa64:/opt/matlabruntime/R2024b/bin/glnxa64:/opt/matlabruntime/R2024b/sys/os/glnxa64:/opt/matlabruntime/R2024b/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2024b/extern/bin/glnxa64:${LD_LIBRARY_PATH:-}"

# Debug info
log "=== DEBUG: File Paths ==="
log "WORK_DIR: $WORK_DIR"
log "WORK_PATH: $WORK_PATH"
log "OUTPUT_DIR: $OUTPUT_DIR"
log "Current directory: $(pwd)"
log "MATLAB executable: $(ls -la /app/FBCSP_Training 2>/dev/null || echo 'Not found')"
log "Dependencies file: $(ls -la /app/Standard-10-20-Cap81.locs 2>/dev/null || echo 'Not found')"
log "MCR_CACHE_ROOT: $MCR_CACHE_ROOT"
log "MATLAB_PREFDIR: $MATLAB_PREFDIR"
log "Work directory contents:"
find "$WORK_DIR" -type f 2>/dev/null | head -10 || true
log "========================"

if [[ -d "/test_data" ]]; then
    log "LOCAL TEST MODE: Skipping MATLAB execution"
    EXIT_CODE=0

    log "Creating dummy result files"
    cat > "$OUTPUT_DIR/classifier_output.json" << EOF
{
  "classifierType": "FBCSP",
  "channels": $EEGChannels,
  "samplingRate": $Frequency,
  "filterBands": [
    [4, 8],
    [8, 12],
    [12, 16],
    [16, 20],
    [20, 24],
    [24, 28]
  ],
  "accuracy": 0.85,
  "timestamp": $(date +%s)
}
EOF

    echo "Test model data" > "$OUTPUT_DIR/model.mat"

    cat > "$OUTPUT_DIR/metadata_output.json" << EOF
{
  "subjectId": "$SubjectID",
  "sessionType": "$SessionType",
  "processingTime": 120,
  "artifactRejectionRate": 0.05,
  "signalQuality": "good",
  "timestamp": $(date +%s)
}
EOF

    cat > "$OUTPUT_DIR/FBCSP_online_setup_prep_01 [online].json" << EOF
{
  "classifierName": "FBCSP_online_setup_prep_01",
  "mode": "online",
  "parameters": {
    "filterOrder": 4,
    "timeWindow": 2.0,
    "overlapWindow": 0.5,
    "featureSelection": "mRMR",
    "classifier": "LDA"
  },
  "timestamp": $(date +%s)
}
EOF
else
    log "Running MATLAB executable"
    ./run_FBCSP_Training.sh "${MATLAB_RUNTIME_ROOT:-/opt/matlabruntime/R2024b}" 2>&1 | while IFS= read -r line; do
        echo "[LOCAL] $(ts) MATLAB $line"
    done
    EXIT_CODE=${PIPESTATUS[0]:-0}

    if [[ $EXIT_CODE -ne 0 ]]; then
        log "ERROR: MATLAB execution failed with exit code $EXIT_CODE"
        exit $EXIT_CODE
    fi
fi

RESULTS_PATH="$USER_ID/$SESSION_ID/results"

MANIFEST="/app/output/manifest.json"
echo '{' > "$MANIFEST"
echo '  "userId": "'"$USER_ID"'",' >> "$MANIFEST"
echo '  "sessionId": "'"$SESSION_ID"'",' >> "$MANIFEST"
echo '  "inputFile": "'"$INPUT_FILE"'",' >> "$MANIFEST"
echo '  "startTime": '"$(date +%s)"',' >> "$MANIFEST"
echo '  "endTime": '"$(date +%s)"',' >> "$MANIFEST"
echo '  "resultsPath": "'"$RESULTS_PATH"'",' >> "$MANIFEST"
echo '  "exitCode": '"$EXIT_CODE"',' >> "$MANIFEST"
echo '  "hasMetadata": true,' >> "$MANIFEST"
echo '  "metadataFile": "metadata_output.json",' >> "$MANIFEST"
echo '  "outputFiles": [' >> "$MANIFEST"

cp -r "$OUTPUT_DIR"/* /app/output/ 2>/dev/null || true

first_file=true
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        if [ "$first_file" = false ]; then
            echo ',' >> "$MANIFEST"
        fi
        relative_path="${file#/app/output/}"
        log "Adding to manifest: $relative_path"
        echo -n '    "'"$relative_path"'"' >> "$MANIFEST"
        first_file=false
    fi
done < <(find /app/output -type f -print0 2>/dev/null)

echo '' >> "$MANIFEST"
echo '  ]' >> "$MANIFEST"
echo '}' >> "$MANIFEST"

if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
    log "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/ using custom endpoint"
    aws_opts="--endpoint-url=$AWS_ENDPOINT_URL"
    aws $aws_opts s3 cp /app/output/ "s3://${RESULTS_BUCKET}/${RESULTS_PATH}/" --recursive

    if [ -f "/app/output/FBCSP_online_setup_prep_01 [online].json" ]; then
        aws $aws_opts s3 cp "/app/output/FBCSP_online_setup_prep_01 [online].json" "s3://${RESULTS_BUCKET}/${USER_ID}/${SESSION_ID}/FBCSP_online_setup_prep_01 [online].json"
    fi

    aws $aws_opts s3 cp "/app/output/manifest.json" "s3://${RESULTS_BUCKET}/${USER_ID}/${SESSION_ID}/manifest.json"
elif [[ -d "/test_data" ]]; then
    log "LOCAL TEST MODE: Copying results to /test_data/output"
    mkdir -p /test_data/output
    cp -r /app/output/* /test_data/output/
else
    log "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/"
    aws s3 cp /app/output/ "s3://${RESULTS_BUCKET}/${RESULTS_PATH}/" --recursive
fi

echo '{"resultsPath": "'"$RESULTS_PATH"'"}'