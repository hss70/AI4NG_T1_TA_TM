#!/bin/bash
set -euo pipefail

# Set fixed environment variables
export WORK_DIR="/app/work"
export HOME_DIR="$WORK_DIR"  # For MATLAB compatibility
export WORK_PATH="$WORK_DIR/Work"
export OUTPUT_DIR="$WORK_DIR/Results"

# Create required directories
mkdir -p \
  "$WORK_DIR/Dependents" \
  "$WORK_PATH/CSV/$USER_ID/$SESSION_ID" \
  "$WORK_PATH/Results" \
  "/app/output"

# Copy the EEG channel locations file to Dependents
cp /app/Standard-10-20-Cap81.locs "$WORK_DIR/Dependents/"

# Check if AWS_ENDPOINT_URL is set for LocalStack
if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
  echo "Using custom S3 endpoint: $AWS_ENDPOINT_URL"
  aws_opts="--endpoint-url=$AWS_ENDPOINT_URL"
  
  # Download input file from LocalStack S3
  echo "Downloading $INPUT_FILE from $UPLOAD_BUCKET using LocalStack"
  aws $aws_opts s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip
elif [[ -d "/test_data" ]]; then
  # For local testing, use mounted volume instead of S3
  echo "LOCAL TEST MODE: Using mounted test data"
  cp /test_data/test_data.zip /app/input.zip
else
  # Download input file from AWS S3
  echo "Downloading $INPUT_FILE from $UPLOAD_BUCKET"
  aws s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip
fi

# Unzip into session directory
echo "Unzipping input file to $WORK_PATH/CSV/$USER_ID/$SESSION_ID"
unzip -o /app/input.zip -d "$WORK_PATH/CSV/$USER_ID/$SESSION_ID"

# Load metadata and set critical variables
METADATA_FILE="$WORK_PATH/CSV/$USER_ID/$SESSION_ID/metadata.json"
if [[ -f "$METADATA_FILE" ]]; then
    echo "Loading metadata from $METADATA_FILE"
    # Extract required parameters
    export EEGChannels=$(jq -r '.EEGChannels' "$METADATA_FILE")
    export Frequency=$(jq -r '.Frequency' "$METADATA_FILE")
    
    # Set MATLAB-required variables
    export channelNum="$EEGChannels"
    export sampleRate="$Frequency"
    export downSampleRate="$Frequency"
    
    # Export other metadata fields as environment variables
    while IFS="=" read -r key value; do
        key="${key//[^a-zA-Z0-9_]/_}"  # Sanitize key
        if [[ ! $key =~ ^(USER_ID|SESSION_ID|INPUT_FILE|UPLOAD_BUCKET|RESULTS_BUCKET)$ ]]; then
            export "$key"="$value"
            echo "Set env: $key : $value"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value | tostring)"' "$METADATA_FILE")
else
    echo "ERROR: metadata.json not found in input ZIP"
    exit 1
fi

# Set MATLAB Runtime library path
export LD_LIBRARY_PATH="/opt/matlabruntime/R2024b/runtime/glnxa64:/opt/matlabruntime/R2024b/bin/glnxa64:/opt/matlabruntime/R2024b/sys/os/glnxa64:/opt/matlabruntime/R2024b/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2024b/extern/bin/glnxa64:${LD_LIBRARY_PATH:-}"

# Debug: Show file paths for MATLAB debugging
echo "=== DEBUG: File Paths ==="
echo "WORK_DIR: $WORK_DIR"
echo "WORK_PATH: $WORK_PATH"
echo "OUTPUT_DIR: $OUTPUT_DIR"
echo "Current directory: $(pwd)"
echo "MATLAB executable: $(ls -la /app/FBCSP_Training 2>/dev/null || echo 'Not found')"
echo "Dependencies file: $(ls -la /app/Standard-10-20-Cap81.locs 2>/dev/null || echo 'Not found')"
echo "Work directory contents:"
find $WORK_DIR -type f 2>/dev/null | head -10
echo "========================"

# For local testing, we'll skip running the actual MATLAB executable
if [[ -d "/test_data" ]]; then
    echo "LOCAL TEST MODE: Skipping MATLAB execution"
    EXIT_CODE=0
    # Create dummy result files
    echo "Creating dummy result files"
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
    # Create the specific file that the state machine looks for
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
    # Run MATLAB executable using the runner script
    echo "Running MATLAB executable"
    start_time=$(date +%s)
    ./run_FBCSP_Training.sh ${MATLAB_RUNTIME_ROOT:-/opt/matlabruntime/R2024b} || EXIT_CODE=$?
    end_time=$(date +%s)
    EXIT_CODE=${EXIT_CODE:-0}

    # Exit immediately if MATLAB failed
    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "ERROR: MATLAB execution failed with exit code $EXIT_CODE"
        exit $EXIT_CODE
    fi
fi

# Generate results path
RESULTS_PATH="$USER_ID/$SESSION_ID/results"

# Create manifest file
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

# Copy all files and directories recursively
cp -r "$OUTPUT_DIR"/* /app/output/ 2>/dev/null || true

# List all output files recursively
first_file=true
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        if [ "$first_file" = false ]; then
            echo ',' >> "$MANIFEST"
        fi
        # Get relative path from /app/output/
        relative_path="${file#/app/output/}"
        echo "Adding to manifest: $relative_path"
        echo -n '    "'"$relative_path"'"' >> "$MANIFEST"
        first_file=false
    fi
done < <(find /app/output -type f -print0 2>/dev/null)

echo '' >> "$MANIFEST"
echo '  ]' >> "$MANIFEST"
echo '}' >> "$MANIFEST"

# Check if AWS_ENDPOINT_URL is set for LocalStack
if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
    echo "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/ using LocalStack"
    aws_opts="--endpoint-url=$AWS_ENDPOINT_URL"
    aws $aws_opts s3 cp /app/output/ "s3://$RESULTS_BUCKET/$RESULTS_PATH/" --recursive
    
    # Also upload the classifier file to the session root for the state machine to find
    if [ -f "/app/output/FBCSP_online_setup_prep_01 [online].json" ]; then
        aws $aws_opts s3 cp "/app/output/FBCSP_online_setup_prep_01 [online].json" "s3://$RESULTS_BUCKET/$USER_ID/$SESSION_ID/FBCSP_online_setup_prep_01 [online].json"
    fi
    
    # Upload manifest to session root
    aws $aws_opts s3 cp "/app/output/manifest.json" "s3://$RESULTS_BUCKET/$USER_ID/$SESSION_ID/manifest.json"
elif [[ -d "/test_data" ]]; then
    # For local testing, copy results to mounted volume
    echo "LOCAL TEST MODE: Copying results to /test_data/output"
    mkdir -p /test_data/output
    cp -r /app/output/* /test_data/output/
else
    # Upload results to AWS S3
    echo "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/"
    aws s3 cp /app/output/ "s3://$RESULTS_BUCKET/$RESULTS_PATH/" --recursive
fi

# Output results for Step Function
echo '{"resultsPath": "'"$RESULTS_PATH"'"}'