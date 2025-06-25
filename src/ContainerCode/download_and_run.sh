#!/bin/bash
set -euo pipefail

# Set fixed environment variables
export WORK_DIR="/app/work"
export HOME_DIR="$WORK_DIR"  # For MATLAB compatibility
export WORK_PATH="$WORK_DIR/Work"
export RESULTS_PATH="$WORK_DIR/Results"

# Create required directories
mkdir -p \
  "$WORK_DIR/Dependents" \
  "$WORK_PATH/CSV/$USER_ID/$SESSION_ID" \
  "$WORK_PATH/Results" \
  "/app/output"

# Copy the EEG channel locations file to Dependents
cp /app/Standard-10-20-Cap81.locs "$WORK_DIR/Dependents/"

# Download input file from S3
echo "Downloading $INPUT_FILE from $UPLOAD_BUCKET"
aws s3 cp "s3://${UPLOAD_BUCKET}/${INPUT_FILE}" /app/input.zip

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
            echo "Set env: $key"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value | tostring)"' "$METADATA_FILE")
else
    echo "ERROR: metadata.json not found in input ZIP"
    exit 1
fi

# Run MATLAB executable using the runner script
echo "Running MATLAB executable"
start_time=$(date +%s)
./run_FBCSP_Training.sh ${MATLAB_RUNTIME_ROOT:-/usr/local/MATLAB/MATLAB_Runtime/v125} || EXIT_CODE=$?
end_time=$(date +%s)
EXIT_CODE=${EXIT_CODE:-0}

# Generate results path
RESULTS_PATH="$USER_ID/$SESSION_ID/results"

# Create manifest file
MANIFEST="/app/output/manifest.json"
echo '{' > "$MANIFEST"
echo '  "userId": "'"$USER_ID"'",' >> "$MANIFEST"
echo '  "sessionId": "'"$SESSION_ID"'",' >> "$MANIFEST"
echo '  "inputFile": "'"$INPUT_FILE"'",' >> "$MANIFEST"
echo '  "startTime": '"$start_time"',' >> "$MANIFEST"
echo '  "endTime": '"$end_time"',' >> "$MANIFEST"
echo '  "resultsPath": "'"$RESULTS_PATH"'",' >> "$MANIFEST"
echo '  "exitCode": '"$EXIT_CODE"',' >> "$MANIFEST"
echo '  "outputFiles": [' >> "$MANIFEST"

# List all output files
first_file=true
for file in "$WORK_DIR/Results"/*; do
    if [ -f "$file" ]; then
        if [ "$first_file" = false ]; then
            echo ',' >> "$MANIFEST"
        fi
        filename=$(basename "$file")
        echo -n '    "'"$filename"'"' >> "$MANIFEST"
        # Move file to output directory
        mv "$file" /app/output/
        first_file=false
    fi
done

echo '' >> "$MANIFEST"
echo '  ]' >> "$MANIFEST"
echo '}' >> "$MANIFEST"

# Upload results to S3
echo "Uploading results to $RESULTS_BUCKET/$RESULTS_PATH/"
aws s3 cp /app/output/ "s3://$RESULTS_BUCKET/$RESULTS_PATH/" --recursive

# Output results for Step Function
echo '{"resultsPath": "'"$RESULTS_PATH"'"}'