#!/bin/bash
# GitStat test runner for kira-test
# Runs all test files and outputs results to .test-results.json
#
# NOTE: Tests that import kira_test.* modules require running from a project
# that has kira_test as a dependency. The standalone examples can run directly.

set -e

RESULTS_FILE=".test-results.json"
PASSED=0
FAILED=0
FAILURES=()

run_test_file() {
    local file="$1"
    echo "Running $file..."

    # Capture output and check for test results
    if output=$(kira run "$file" 2>&1); then
        echo "$output"

        # Parse output for pass/fail counts
        # Format: "X passed" and "Y failed" on separate lines
        if echo "$output" | grep -qE '[0-9]+ passed'; then
            local p=$(echo "$output" | grep -oE '[0-9]+ passed' | head -1 | grep -oE '[0-9]+')
            local f=$(echo "$output" | grep -oE '[0-9]+ failed' | head -1 | grep -oE '[0-9]+' || echo "0")
            PASSED=$((PASSED + p))
            FAILED=$((FAILED + f))

            # Capture failure names if any
            if [ "$f" -gt 0 ]; then
                while IFS= read -r line; do
                    if echo "$line" | grep -qE "FAILED|FAIL:"; then
                        FAILURES+=("$line")
                    fi
                done <<< "$output"
            fi
        # Check for PASSED in output (standalone tests)
        elif echo "$output" | grep -q "PASSED"; then
            PASSED=$((PASSED + 1))
        else
            # If no recognized output, assume success if exit code 0
            PASSED=$((PASSED + 1))
        fi
    else
        echo "$output"
        FAILED=$((FAILED + 1))
        FAILURES+=("$file: execution failed")
    fi
}

echo "=== Running kira-test test suite ==="
echo ""

# Run internal tests (use direct imports, work from within package)
echo "--- Internal Tests ---"
if [ -f "tests/internal_tests.ki" ]; then
    run_test_file "tests/internal_tests.ki"
    echo ""
fi

# Run standalone examples
echo "--- Standalone Examples ---"
for test_file in examples/standalone_test.ki; do
    if [ -f "$test_file" ]; then
        run_test_file "$test_file"
        echo ""
    fi
done

TOTAL=$((PASSED + FAILED))

echo "=== Test Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $TOTAL"

# Write results to JSON file
if [ ${#FAILURES[@]} -eq 0 ]; then
    cat > "$RESULTS_FILE" << EOF
{
  "passed": $PASSED,
  "failed": $FAILED,
  "total": $TOTAL,
  "failures": []
}
EOF
else
    # Build failures array
    FAILURES_JSON="["
    for i in "${!FAILURES[@]}"; do
        if [ $i -gt 0 ]; then
            FAILURES_JSON+=","
        fi
        # Escape quotes in failure message
        escaped=$(echo "${FAILURES[$i]}" | sed 's/"/\\"/g')
        FAILURES_JSON+="\"$escaped\""
    done
    FAILURES_JSON+="]"

    cat > "$RESULTS_FILE" << EOF
{
  "passed": $PASSED,
  "failed": $FAILED,
  "total": $TOTAL,
  "failures": $FAILURES_JSON
}
EOF
fi

echo ""
echo "Results written to $RESULTS_FILE"

# Exit with failure if any tests failed
[ $FAILED -eq 0 ]
