#!/bin/bash
set -e

# Configuration
USER_ID="test_user"
SESSION_ID="test_session"
INPUT_FILE="uploads/$USER_ID/$SESSION_ID/test_data.zip"

echo "=== AI4NG EEG Processing Pipeline Local Test ==="
echo "User ID: $USER_ID"
echo "Session ID: $SESSION_ID"

# Step 1: Extract Session Info (simulated)
echo -e "\n=== Step 1: Extract Session Info ==="
echo "Extracted user ID: $USER_ID"
echo "Extracted session ID: $SESSION_ID"
echo "Input file path: $INPUT_FILE"

# Step 2: Record Processing Start (simulated)
echo -e "\n=== Step 2: Record Processing Start ==="
echo "Recording processing start in simulated DynamoDB..."
echo "{\"sessionId\": \"$SESSION_ID\", \"userId\": \"$USER_ID\", \"status\": \"PROCESSING\", \"startTime\": \"$(date -Iseconds)\"}" > test_data/status.json

# Step 3: Prepare test data
echo -e "\n=== Step 3: Preparing Test Data ==="
mkdir -p test_data/input
mkdir -p test_data/output

# Create a simple metadata.json for testing
cat > test_data/input/metadata.json << EOF
{
  "EEGChannels": 64,
  "Frequency": 250,
  "SubjectID": "test_subject",
  "SessionType": "training",
  "hasMetadata": true
}
EOF

# Create dummy CSV files
echo "Creating dummy EEG data files..."
touch test_data/input/channel1.csv
touch test_data/input/channel2.csv

# Create a test zip file
echo "Creating test zip file..."
cd test_data/input
zip -r ../test_data.zip ./*
cd ../..

# Step 4: Build and run the container
echo -e "\n=== Step 4: Launch Container (ECS Task equivalent) ==="
echo "Building Docker image..."
sudo docker build -t eeg-classifier:local -f Dockerfile.local .

echo "Running container with test data..."
sudo docker run --rm \
  -v "$(pwd)/test_data:/test_data" \
  -e USER_ID=$USER_ID \
  -e SESSION_ID=$SESSION_ID \
  -e INPUT_FILE=$INPUT_FILE \
  -e UPLOAD_BUCKET=test_bucket \
  -e RESULTS_BUCKET=test_bucket \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=eu-west-2 \
  eeg-classifier:local

# Step 5: Process Manifest (simulated)
echo -e "\n=== Step 5: Process Manifest ==="
if [ -f "test_data/output/manifest.json" ]; then
  echo "Manifest file found. Processing..."
  cat test_data/output/manifest.json
  
  # Extract info from manifest
  HAS_METADATA=$(grep -o '"hasMetadata":\s*true' test_data/output/manifest.json || echo "false")
  
  # Step 6: Process Classifier Output (simulated)
  echo -e "\n=== Step 6: Process Classifier Output ==="
  if [ -f "test_data/output/classifier_output.json" ]; then
    echo "Classifier output found. Processing..."
    cat test_data/output/classifier_output.json
  else
    echo "No classifier output found."
  fi
  
  # Step 7: Process Metadata if available (simulated)
  if [[ "$HAS_METADATA" == *"true"* ]]; then
    echo -e "\n=== Step 7: Process Metadata ==="
    if [ -f "test_data/output/metadata_output.json" ]; then
      echo "Metadata found. Processing..."
      cat test_data/output/metadata_output.json
    else
      echo "No metadata output found, but hasMetadata was true."
    fi
  fi
  
  # Step 8: Record Success (simulated)
  echo -e "\n=== Step 8: Record Success ==="
  echo "{\"sessionId\": \"$SESSION_ID\", \"userId\": \"$USER_ID\", \"status\": \"SUCCESS\", \"endTime\": \"$(date -Iseconds)\"}" > test_data/status_final.json
  echo "Final status recorded:"
  cat test_data/status_final.json
else
  # Record Failure (simulated)
  echo -e "\n=== Step 8: Record Failure ==="
  echo "No manifest file found. Recording failure."
  echo "{\"sessionId\": \"$SESSION_ID\", \"userId\": \"$USER_ID\", \"status\": \"FAILED\", \"error\": \"Manifest file not found\", \"endTime\": \"$(date -Iseconds)\"}" > test_data/status_final.json
  echo "Final status recorded:"
  cat test_data/status_final.json
  exit 1
fi

echo -e "\n=== Test Pipeline Complete ==="
echo "Results available in: test_data/output/"