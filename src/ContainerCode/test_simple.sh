#!/bin/bash
set -e

# Configuration
USER_ID="test_user"
SESSION_ID="test_session"
INPUT_FILE="uploads/$USER_ID/$SESSION_ID/test_data.zip"
TEST_DATA_PATH="/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData/TestUpload_20250618121942.zip"

echo "=== AI4NG EEG Processing Pipeline Simple Test ==="

# Prepare test directories
mkdir -p test_data/input
mkdir -p test_data/output

# Copy the test data
echo "Copying test data..."
cp "$TEST_DATA_PATH" test_data/test_data.zip

# Build the Docker image
echo "Building Docker image..."
sudo docker build -t eeg-classifier:local -f Dockerfile.local .

# Run container with test data
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

echo "Test complete! Results available in test_data/output/"