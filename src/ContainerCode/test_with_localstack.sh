#!/bin/bash
sudo set -e

# Cleanup function
cleanup() {
    echo "\n=== Cleanup triggered ==="
    sudo docker stop localstack 2>/dev/null || true
    sudo docker rm localstack 2>/dev/null || true
    sudo docker rm eeg-test-container 2>/dev/null || true
    sudo docker network rm eeg-test-network 2>/dev/null || true
    echo "Cleanup completed"
}

# Set trap to run cleanup on script exit (success or failure)
#trap cleanup EXIT

if [[ "$(uname)" == "Linux" ]]; then
    echo "Starting MATLAB compilation..."
    compile_start=$(date +%s)
    ./compile_matlab.sh #ensures fresh compilation
    compile_end=$(date +%s)
    compile_duration=$((compile_end - compile_start))
    echo "MATLAB compilation completed in ${compile_duration} seconds"
else
    echo "Skipping MATLAB compilation (not on Linux). Can only compile on Linux for docker image."
fi

# Configuration
USER_ID="test_user"
SESSION_ID="test_session"
INPUT_FILE="uploads/$USER_ID/$SESSION_ID/test_data.zip"
TEST_DATA_PATH="/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData/TestUpload_20250618121942.zip"

echo "=== AI4NG EEG Processing Pipeline LocalStack Test ==="

# Use the user's AWS CLI when running with sudo
export PATH=$PATH:/home/hardeep/.local/bin

# Start LocalStack
echo "Starting LocalStack..."
# Check if LocalStack is already running
if sudo docker ps | grep -q localstack; then
    echo "LocalStack is already running, reusing existing container"
else
    # Remove any stopped localstack container
    sudo docker rm -f localstack 2>/dev/null || true
    echo "Starting new LocalStack container..."
    sudo docker run -d --name localstack -p 4566:4566 -e SERVICES=s3,dynamodb localstack/localstack:latest
fi

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
sleep 10

# Create S3 buckets
echo "Creating S3 buckets..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-upload-bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-results-bucket

# Create DynamoDB table
echo "Creating DynamoDB table..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name EEGProcessingStatus \
  --attribute-definitions AttributeName=sessionId,AttributeType=S \
  --key-schema AttributeName=sessionId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Upload test data to S3
echo "Uploading test data to S3..."
USER_ID="test_user"
SESSION_ID="test_session"
INPUT_FILE="uploads/$USER_ID/$SESSION_ID/test_data.zip"
TEST_DATA_PATH="/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData/TestUpload_20250618121942.zip"
aws --endpoint-url=http://localhost:4566 s3 cp "$TEST_DATA_PATH" "s3://test-upload-bucket/$INPUT_FILE"

# Record processing start in DynamoDB
echo "Recording processing start in DynamoDB..."
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name EEGProcessingStatus \
  --item '{"sessionId": {"S": "test_session"}, "userId": {"S": "test_user"}, "status": {"S": "PROCESSING"}, "startTime": {"S": "'$(date -Iseconds)'"}}'

# Create Docker network
sudo docker network create eeg-test-network || true
sudo docker network connect eeg-test-network localstack || true

# Build the Docker image
echo "Building Docker image..."
sudo docker build -t eeg-classifier:local -f Dockerfile.local .

# Run container with LocalStack
echo "Running container with LocalStack..."

containerRunStart=$(date +%s)

sudo docker run --name eeg-test-container \
  --network eeg-test-network \
  -e USER_ID=$USER_ID \
  -e SESSION_ID=$SESSION_ID \
  -e INPUT_FILE=$INPUT_FILE \
  -e UPLOAD_BUCKET=test-upload-bucket \
  -e RESULTS_BUCKET=test-results-bucket \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=eu-west-2 \
  -e AWS_ENDPOINT_URL=http://localstack:4566 \
  eeg-classifier:local 2>&1 | tee container.log

containerRunEnd=$(date +%s)
containerRunDuration=$((containerRunEnd - containerRunStart))
echo "Container run completed in ${containerRunDuration} seconds"
echo "=== Checking if container exists ==="
sudo docker ps -a | grep eeg-test-container || echo "Container not found in docker ps"

# Debug: Show all files in a test container
echo "=== DEBUG: Container File Structure ==="
sudo docker run --rm \
  --network eeg-test-network \
  -e USER_ID=$USER_ID \
  -e SESSION_ID=$SESSION_ID \
  --entrypoint /bin/bash \
  eeg-classifier:local -c "
echo 'Container ID:' && hostname
echo '=== Root directory ==='
ls -la /
echo '=== App directory structure ==='
find /app -type d 2>/dev/null | head -20
echo '=== All files in /app (first 50) ==='
find /app -type f 2>/dev/null | head -50
echo '=== MATLAB files ==='
find /app -name '*.m' 2>/dev/null
echo '=== Work directory ==='
ls -la /app/work/ 2>/dev/null || echo 'work dir not found'
echo '=== Environment variables ==='
env | grep -E '(USER_ID|SESSION_ID|BUCKET)'
echo '=== Current working directory ==='
pwd
echo '=== Disk usage ==='
df -h
"
echo "========================"

# Download results from S3
echo "Downloading results from S3..."
mkdir -p ../../TestData/ContainerTests/test_results
aws --endpoint-url=http://localhost:4566 s3 cp "s3://test-results-bucket/$USER_ID/$SESSION_ID/results/" ../../TestData/ContainerTests/test_results/ --recursive

# Check for classifier file
if aws --endpoint-url=http://localhost:4566 s3 ls "s3://test-results-bucket/$USER_ID/$SESSION_ID/FBCSP_online_setup_prep_01 [online].json" &>/dev/null; then
  echo "Classifier file found. Processing..."
  aws --endpoint-url=http://localhost:4566 s3 cp "s3://test-results-bucket/$USER_ID/$SESSION_ID/FBCSP_online_setup_prep_01 [online].json" ../../TestData/ContainerTests/test_results/
  
  # Update status to SUCCESS
  aws --endpoint-url=http://localhost:4566 dynamodb update-item \
    --table-name EEGProcessingStatus \
    --key '{"sessionId": {"S": "test_session"}}' \
    --update-expression "SET #s = :status, #e = :endTime" \
    --expression-attribute-names '{"#s": "status", "#e": "endTime"}' \
    --expression-attribute-values '{":status": {"S": "SUCCESS"}, ":endTime": {"S": "'$(date -Iseconds)'"}}'
else
  echo "Classifier file not found. Recording failure."
  # Update status to FAILED
  aws --endpoint-url=http://localhost:4566 dynamodb update-item \
    --table-name EEGProcessingStatus \
    --key '{"sessionId": {"S": "test_session"}}' \
    --update-expression "SET #s = :status, #e = :endTime, #err = :error" \
    --expression-attribute-names '{"#s": "status", "#e": "endTime", "#err": "error"}' \
    --expression-attribute-values '{":status": {"S": "FAILED"}, ":endTime": {"S": "'$(date -Iseconds)'"}, ":error": {"S": "Classifier file not found"}}'
fi

# Check processing status
echo "Checking processing status in DynamoDB..."
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
  --table-name EEGProcessingStatus \
  --key '{"sessionId": {"S": "test_session"}}'

# Copy all container files for inspection
echo "=== Copying container files ==="
if sudo docker ps -a | grep -q eeg-test-container; then
    echo "Copying all container files to ../../TestData/ContainerTests/container_files/"
    mkdir -p ../../TestData/ContainerTests/container_files
    echo "Cleaning existing files from container_files directory..."
    rm -rf ../../TestData/ContainerTests/container_files/*
    sudo docker cp eeg-test-container:/app ../../TestData/ContainerTests/container_files/
    sudo chown -R $(whoami):$(whoami) ../../TestData/ContainerTests/container_files/
    echo "Container files copied successfully"
    echo "Container file structure:"
    find ../../TestData/ContainerTests/container_files -type f | head -20
else
    echo "Container not found for file copying"
fi

# Additional debug: Check container logs if it exists
echo "=== Checking container logs ==="
if sudo docker ps -a | grep -q eeg-test-container; then
    echo "Container exists, showing logs:"
    sudo docker logs eeg-test-container | tail -50
else
    echo "Container not found for log inspection"
fi

echo "Test complete! Results available in ../../TestData/ContainerTests/test_results/"

cleanup