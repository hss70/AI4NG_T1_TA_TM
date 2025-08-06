#!/bin/bash
set -e

# Build the Docker image
echo "Building Docker image..."
docker build -t eeg-classifier:local -f Dockerfile.local .

# Create test directories
mkdir -p test_data/input
mkdir -p test_data/output

# Create a simple metadata.json for testing
cat > test_data/input/metadata.json << EOF
{
  "EEGChannels": 64,
  "Frequency": 250,
  "SubjectID": "test_subject",
  "SessionType": "training"
}
EOF

# Create dummy CSV files (would be your actual EEG data in production)
echo "Creating dummy EEG data files..."
touch test_data/input/channel1.csv
touch test_data/input/channel2.csv

# Create a test zip file
echo "Creating test zip file..."
cd test_data/input
zip -r ../test_data.zip ./*
cd ../..

echo "Running container with test data..."
docker run --rm \
  -v "$(pwd)/test_data:/test_data" \
  -e USER_ID=test_user \
  -e SESSION_ID=test_session \
  -e INPUT_FILE=uploads/test_user/test_session/test_data.zip \
  -e UPLOAD_BUCKET=test_bucket \
  -e RESULTS_BUCKET=test_bucket \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=eu-west-2 \
  eeg-classifier:local

echo "Test complete!"