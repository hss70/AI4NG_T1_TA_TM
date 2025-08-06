#!/bin/bash
set -e

echo "=== Simulink Docker Local Test ==="

# Create test directories
mkdir -p test_data/output

# Build the Docker image
echo "Building Docker image..."
docker build -t simulink-test:local -f Dockerfile.local .

# Run container with test data
echo "Running container..."
docker run --rm \
  -v "$(pwd)/test_data:/test_data" \
  simulink-test:local

echo "Test complete! Results available in test_data/output/"

# Display results
if [ -f "test_data/output/test_results.json" ]; then
    echo "Test Results:"
    cat test_data/output/test_results.json
fi