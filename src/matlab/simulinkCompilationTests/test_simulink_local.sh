#!/bin/bash
set -euo pipefail

echo "=== Simulink Compiled Code Test ==="

# Set MATLAB Runtime library path
export LD_LIBRARY_PATH="/opt/matlabruntime/R2024b/runtime/glnxa64:/opt/matlabruntime/R2024b/bin/glnxa64:/opt/matlabruntime/R2024b/sys/os/glnxa64:/opt/matlabruntime/R2024b/sys/opengl/lib/glnxa64:/opt/matlabruntime/R2024b/extern/bin/glnxa64:${LD_LIBRARY_PATH:-}"

# Create output directory
mkdir -p /app/output

echo "Running Simulink validation test..."
start_time=$(date +%s)

# Run the compiled MATLAB executable
./run_validate_compiled_output.sh ${MATLAB_RUNTIME_ROOT:-/opt/matlabruntime/R2024b} || EXIT_CODE=$?
EXIT_CODE=${EXIT_CODE:-0}

end_time=$(date +%s)

# Create test results
cat > /app/output/test_results.json << EOF
{
  "testName": "simulink_validation",
  "startTime": $start_time,
  "endTime": $end_time,
  "exitCode": $EXIT_CODE,
  "duration": $((end_time - start_time)),
  "status": "$([ $EXIT_CODE -eq 0 ] && echo "PASSED" || echo "FAILED")"
}
EOF

# Copy any log files if they exist
if [ -d "logs" ]; then
    cp -r logs /app/output/
fi

# Output results
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Simulink validation test PASSED"
else
    echo "❌ Simulink validation test FAILED with exit code $EXIT_CODE"
fi

# For local testing, copy results to mounted volume if available
if [[ -d "/test_data" ]]; then
    echo "LOCAL TEST MODE: Copying results to /test_data/output"
    mkdir -p /test_data/output
    cp -r /app/output/* /test_data/output/
fi

exit $EXIT_CODE