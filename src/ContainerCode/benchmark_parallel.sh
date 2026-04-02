#!/usr/bin/env bash

set -e

IMAGE="fbcsp-training:local"
TEST_DATA_PATH="$(pwd)/../../TestData"

RUNS=3
CSV_FILE="benchmark_results.csv"
LOG_DIR="benchmark_logs"

mkdir -p "$LOG_DIR"

# Write CSV header
echo "label,parallel_enabled,workers,run_number,duration_ms,duration_s,log_file" > "$CSV_FILE"

echo "=== FBCSP Parallel Benchmark ==="
echo "Runs per config: $RUNS"
echo "CSV output: $CSV_FILE"
echo "Logs dir: $LOG_DIR"
echo

results=()

run_case() {
  local label="$1"
  local parallel_enabled="$2"
  local workers="$3"

  echo "----------------------------------------"
  echo "Running: $label"

  local total=0
  local min=999999999
  local max=0

  for i in $(seq 1 $RUNS); do
    local log_file="${LOG_DIR}/${label}_run${i}.log"

    echo "  Run $i..."

    local start_ms
    local end_ms
    local duration_ms
    local duration_s

    start_ms=$(date +%s%3N)

    docker run --rm \
      -e USER_ID=test-user \
      -e SESSION_ID=test-session \
      -e INPUT_FILE=test_data.zip \
      -e UPLOAD_BUCKET=dummy-upload \
      -e RESULTS_BUCKET=dummy-results \
      -e PARALLEL_ENABLED="$parallel_enabled" \
      -e PARALLEL_WORKERS="$workers" \
      -e PARALLEL_PROFILE_FILE= \
      -v "$TEST_DATA_PATH:/test_data" \
      "$IMAGE" > "$log_file" 2>&1

    end_ms=$(date +%s%3N)
    duration_ms=$((end_ms - start_ms))
    duration_s=$(awk "BEGIN {printf \"%.3f\", $duration_ms/1000}")

    echo "    ${duration_ms} ms (${duration_s} s)"
    echo "    log: $log_file"

    echo "${label},${parallel_enabled},${workers},${i},${duration_ms},${duration_s},${log_file}" >> "$CSV_FILE"

    total=$((total + duration_ms))

    if [ "$duration_ms" -lt "$min" ]; then min=$duration_ms; fi
    if [ "$duration_ms" -gt "$max" ]; then max=$duration_ms; fi
  done

  local avg=$((total / RUNS))
  local avg_s
  local min_s
  local max_s

  avg_s=$(awk "BEGIN {printf \"%.2f\", $avg/1000}")
  min_s=$(awk "BEGIN {printf \"%.2f\", $min/1000}")
  max_s=$(awk "BEGIN {printf \"%.2f\", $max/1000}")

  echo "  → avg=${avg_s}s min=${min_s}s max=${max_s}s"

  results+=("$label:$avg_s:$min_s:$max_s")
}

run_case "serial" 0 1
run_case "parallel-1" 1 1
run_case "parallel-2" 1 2
run_case "parallel-3" 1 3
run_case "parallel-4" 1 4

echo
echo "=== Summary ==="
for r in "${results[@]}"; do
  label=$(echo "$r" | cut -d: -f1)
  avg=$(echo "$r" | cut -d: -f2)
  min=$(echo "$r" | cut -d: -f3)
  max=$(echo "$r" | cut -d: -f4)

  echo "$label -> avg=${avg}s (min=${min}s max=${max}s)"
done

echo
echo "Detailed results written to: $CSV_FILE"
echo "Logs written to: $LOG_DIR/"
