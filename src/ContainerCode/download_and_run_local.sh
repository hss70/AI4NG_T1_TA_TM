#!/bin/bash
set -euo pipefail

ts() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log() {
  echo "[LOCAL] $(ts) $1"
}

# =========================
# Environment Setup
# =========================

export WORK_DIR="/app/work"
export HOME_DIR="$WORK_DIR"
export WORK_PATH="$WORK_DIR/Work"
export OUTPUT_DIR="$WORK_DIR/Results"

export PARALLEL_ENABLED="${PARALLEL_ENABLED:-1}"
export PARALLEL_WORKERS="${PARALLEL_WORKERS:-2}"
export PARALLEL_PROFILE_FILE="${PARALLEL_PROFILE_FILE:-}"

export LOCAL_SKIP_MATLAB="${LOCAL_SKIP_MATLAB:-0}"

export MCR_CACHE_ROOT="${MCR_CACHE_ROOT:-/tmp/mcr-cache}"
export MATLAB_PREFDIR="${MATLAB_PREFDIR:-/tmp/matlab-prefs}"

log "Parallel enabled=${PARALLEL_ENABLED} workers=${PARALLEL_WORKERS} profile=${PARALLEL_PROFILE_FILE:-'(unset)'}"
log "LOCAL_SKIP_MATLAB=${LOCAL_SKIP_MATLAB}"

# =========================
# Directory Setup (FIXED)
# =========================

mkdir -p \
  "$WORK_DIR/Dependents" \
  "$WORK_PATH/CSV/$USER_ID/$SESSION_ID" \
  "$WORK_PATH/Results" \
  "$OUTPUT_DIR" \
  "/app/output" \
  "$MCR_CACHE_ROOT" \
  "$MATLAB_PREFDIR"

# =========================
# Copy Dependencies
# =========================

cp /app/Standard-10-20-Cap81.locs "$WORK_DIR/Dependents/"

# =========================
# Input Handling
# =========================

if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
  log "Using custom S3 endpoint: $AWS_ENDPOINT_URL"
  aws_opts="--endpoint-url=$AWS_ENDPOINT_URL"
  aws $aws_opts s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip

elif [[ -d "/test_data" ]]; then
  log "LOCAL TEST MODE: Using mounted test data"
  cp /test_data/test_data.zip /app/input.zip

else
  log "Downloading $INPUT_FILE from $UPLOAD_BUCKET"
  aws s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip
fi

# =========================
# Unzip Input
# =========================

log "Unzipping input file"
unzip -o /app/input.zip -d "$WORK_PATH/CSV/$USER_ID/$SESSION_ID"

# =========================
# Metadata Handling
# =========================

METADATA_FILE="$WORK_PATH/CSV/$USER_ID/$SESSION_ID/metadata.json"

if [[ -f "$METADATA_FILE" ]]; then
    log "Loading metadata"

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
    log "ERROR: metadata.json not found"
    exit 1
fi

# =========================
# MATLAB Runtime Setup
# =========================

export LD_LIBRARY_PATH="/opt/matlabruntime/R2024b/runtime/glnxa64:/opt/matlabruntime/R2024b/bin/glnxa64:/opt/matlabruntime/R2024b/sys/os/glnxa64:/opt/matlabruntime/R2024b/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2024b/extern/bin/glnxa64:${LD_LIBRARY_PATH:-}"

# =========================
# Debug Info
# =========================

log "=== DEBUG ==="
log "WORK_DIR: $WORK_DIR"
log "OUTPUT_DIR: $OUTPUT_DIR"
log "MCR_CACHE_ROOT: $MCR_CACHE_ROOT"
log "MATLAB_PREFDIR: $MATLAB_PREFDIR"
log "Files:"
find "$WORK_DIR" -type f | head -10 || true
log "============="

# =========================
# MATLAB Execution (NEW FLAG)
# =========================

if [[ "$LOCAL_SKIP_MATLAB" == "1" ]]; then
    log "Skipping MATLAB execution (LOCAL_SKIP_MATLAB=1)"
    EXIT_CODE=0

    log "Creating dummy outputs"

    echo '{"dummy": true}' > "$OUTPUT_DIR/classifier_output.json"
    echo "dummy model" > "$OUTPUT_DIR/model.mat"

else
    log "Running MATLAB executable"

    ./run_FBCSP_Training.sh "${MATLAB_RUNTIME_ROOT:-/opt/matlabruntime/R2024b}" 2>&1 | while IFS= read -r line; do
        echo "[LOCAL] $(ts) MATLAB $line"
    done

    EXIT_CODE=${PIPESTATUS[0]:-0}

    if [[ $EXIT_CODE -ne 0 ]]; then
        log "ERROR: MATLAB failed with exit code $EXIT_CODE"
        exit $EXIT_CODE
    fi
fi

# =========================
# Output Handling
# =========================

RESULTS_PATH="$USER_ID/$SESSION_ID/results"

cp -r "$OUTPUT_DIR"/* /app/output/ 2>/dev/null || true

# =========================
# Final Output
# =========================

echo '{"resultsPath": "'"$RESULTS_PATH"'"}'