# Test script for local container testing
cd ..
# Build the container
Write-Host "Building container..."
Set-Location src/ContainerCode
docker build -t eeg-classifier:test .

# Test MATLAB Runtime paths
Write-Host "Testing MATLAB Runtime installation..."
docker run --rm eeg-classifier:test ls -la /opt/matlabruntime/R2024b/

# Test library paths
Write-Host "Testing library paths..."
docker run --rm eeg-classifier:test ldd /app/FBCSP_Training

Write-Host "Container test complete"