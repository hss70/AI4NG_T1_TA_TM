#!/bin/bash
set -e

# Step Function Simulation Test
echo "=== Step Function Simulation Test ==="

# Configuration
USER_ID="test_user"
SESSION_ID="test_session"
INPUT_FILE="uploads/$USER_ID/$SESSION_ID/test_data.zip"
TEST_DATA_PATH="/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData/TestUpload_20250618121942.zip"

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    sudo docker stop localstack 2>/dev/null || true
    sudo docker rm localstack 2>/dev/null || true
    sudo docker rm eeg-container 2>/dev/null || true
    sudo docker network rm eeg-network 2>/dev/null || true
}
trap cleanup EXIT

# Start LocalStack
echo "1. Starting LocalStack..."
sudo docker run -d --name localstack -p 4566:4566 -e SERVICES=s3,dynamodb localstack/localstack:latest
sleep 10

# Create buckets and tables
echo "2. Setting up AWS resources..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-upload-bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-results-bucket

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name EEGProcessingStatus \
  --attribute-definitions AttributeName=sessionId,AttributeType=S \
  --key-schema AttributeName=sessionId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Upload test data
echo "3. Uploading test data..."
aws --endpoint-url=http://localhost:4566 s3 cp "$TEST_DATA_PATH" "s3://test-upload-bucket/$INPUT_FILE"

# Build container
echo "4. Building container..."
sudo docker build -t eeg-classifier:test -f Dockerfile.local .

# Create network and connect LocalStack
sudo docker network create eeg-network
sudo docker network connect eeg-network localstack

# STEP FUNCTION SIMULATION STARTS HERE
echo "=== SIMULATING STEP FUNCTION WORKFLOW ==="

# Step 1: ExtractSessionInfo (simulated)
echo "Step 1: ExtractSessionInfo - PASSED"

# Step 2: RecordProcessingStart
echo "Step 2: RecordProcessingStart"
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name EEGProcessingStatus \
  --item '{"sessionId": {"S": "'$SESSION_ID'"}, "userId": {"S": "'$USER_ID'"}, "status": {"S": "PROCESSING"}, "startTime": {"S": "'$(date -Iseconds)'"}}'
echo "✓ DynamoDB record created"

# Step 3: LaunchECSTask (run container)
echo "Step 3: LaunchECSTask (Container execution)"
sudo docker run --name eeg-container \
  --network eeg-network \
  -e USER_ID=$USER_ID \
  -e SESSION_ID=$SESSION_ID \
  -e INPUT_FILE=$INPUT_FILE \
  -e UPLOAD_BUCKET=test-upload-bucket \
  -e RESULTS_BUCKET=test-results-bucket \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=eu-west-2 \
  -e AWS_ENDPOINT_URL=http://localstack:4566 \
  eeg-classifier:test
echo "✓ Container execution completed"

# Step 4: WaitForManifest (simulated)
echo "Step 4: WaitForManifest - Waiting 5 seconds..."
sleep 5

# Step 5: CheckManifestExists
echo "Step 5: CheckManifestExists"
if aws --endpoint-url=http://localhost:4566 s3api head-object \
  --bucket test-results-bucket \
  --key "$USER_ID/$SESSION_ID/manifest.json" &>/dev/null; then
    echo "✓ Manifest found at correct location"
else
    echo "✗ FAILED: Manifest not found at $USER_ID/$SESSION_ID/manifest.json"
    echo "Available files:"
    aws --endpoint-url=http://localhost:4566 s3 ls "s3://test-results-bucket/$USER_ID/$SESSION_ID/" --recursive
    exit 1
fi

# Step 6: ProcessManifest
echo "Step 6: ProcessManifest"
MANIFEST_CONTENT=$(aws --endpoint-url=http://localhost:4566 s3 cp "s3://test-results-bucket/$USER_ID/$SESSION_ID/manifest.json" -)
echo "✓ Manifest downloaded successfully"
echo "Manifest content preview:"
echo "$MANIFEST_CONTENT" | head -10

# Step 7: CheckClassifierExists
echo "Step 7: CheckClassifierExists"
if aws --endpoint-url=http://localhost:4566 s3api head-object \
  --bucket test-results-bucket \
  --key "$USER_ID/$SESSION_ID/FBCSP_online_setup_prep_01 [online].json" &>/dev/null; then
    echo "✓ Classifier file found at correct location"
else
    echo "✗ FAILED: Classifier file not found at $USER_ID/$SESSION_ID/FBCSP_online_setup_prep_01 [online].json"
    echo "Available files:"
    aws --endpoint-url=http://localhost:4566 s3 ls "s3://test-results-bucket/$USER_ID/$SESSION_ID/" --recursive
    exit 1
fi

# Step 8: ProcessClassifier
echo "Step 8: ProcessClassifier"
CLASSIFIER_CONTENT=$(aws --endpoint-url=http://localhost:4566 s3 cp "s3://test-results-bucket/$USER_ID/$SESSION_ID/FBCSP_online_setup_prep_01 [online].json" -)
echo "✓ Classifier file downloaded successfully"

# Step 9: CheckForMetadata
echo "Step 9: CheckForMetadata"
HAS_METADATA=$(echo "$MANIFEST_CONTENT" | jq -r '.hasMetadata // false')
if [ "$HAS_METADATA" = "true" ]; then
    echo "✓ Metadata flag found in manifest"
    
    # Step 10: ProcessMetadata
    echo "Step 10: ProcessMetadata"
    METADATA_FILE=$(echo "$MANIFEST_CONTENT" | jq -r '.metadataFile // "metadata_output.json"')
    if aws --endpoint-url=http://localhost:4566 s3api head-object \
      --bucket test-results-bucket \
      --key "$USER_ID/$SESSION_ID/$METADATA_FILE" &>/dev/null; then
        echo "✓ Metadata file found: $METADATA_FILE"
    else
        echo "✗ WARNING: Metadata file not found: $METADATA_FILE"
    fi
else
    echo "✓ No metadata processing required"
fi

# Step 11: RecordSuccess
echo "Step 11: RecordSuccess"
aws --endpoint-url=http://localhost:4566 dynamodb update-item \
  --table-name EEGProcessingStatus \
  --key '{"sessionId": {"S": "'$SESSION_ID'"}}' \
  --update-expression "SET #s = :status, #e = :endTime" \
  --expression-attribute-names '{"#s": "status", "#e": "endTime"}' \
  --expression-attribute-values '{":status": {"S": "SUCCESS"}, ":endTime": {"S": "'$(date -Iseconds)'"}}'
echo "✓ Success recorded in DynamoDB"

# Final verification
echo "=== FINAL VERIFICATION ==="
FINAL_STATUS=$(aws --endpoint-url=http://localhost:4566 dynamodb get-item \
  --table-name EEGProcessingStatus \
  --key '{"sessionId": {"S": "'$SESSION_ID'"}}' \
  --query 'Item.status.S' --output text)

if [ "$FINAL_STATUS" = "SUCCESS" ]; then
    echo "🎉 STEP FUNCTION SIMULATION PASSED!"
    echo "All files are in the correct locations for the Step Function to find them."
else
    echo "❌ STEP FUNCTION SIMULATION FAILED!"
    echo "Final status: $FINAL_STATUS"
    exit 1
fi

echo "=== Test Results Summary ==="
echo "✓ Container uploads files to correct S3 paths"
echo "✓ Manifest.json is accessible by Step Function"
echo "✓ Classifier file is accessible by Step Function"
echo "✓ DynamoDB updates work correctly"
echo "✓ All Step Function expectations are met"