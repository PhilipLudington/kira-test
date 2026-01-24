#!/bin/bash
# GitStat build script for kira-test
# Runs kira check on all source files and outputs results to .build-results.json

RESULTS_FILE=".build-results.json"
ERRORS=0
WARNINGS=0
MESSAGES=()
SUCCESS=true

echo "=== Running kira check on all source files ==="
echo ""

# Check all .ki files in root and subdirectories
for file in *.ki tests/*.ki examples/*.ki; do
    if [ -f "$file" ]; then
        echo "Checking $file..."
        if output=$(kira check "$file" 2>&1); then
            echo "  ✓ $file"
            # Check for warnings in output
            if echo "$output" | grep -qi "warning"; then
                w=$(echo "$output" | grep -ci "warning" || echo "0")
                WARNINGS=$((WARNINGS + w))
                while IFS= read -r line; do
                    if echo "$line" | grep -qi "warning"; then
                        MESSAGES+=("$file: $line")
                    fi
                done <<< "$output"
            fi
        else
            echo "  ✗ $file"
            SUCCESS=false
            ERRORS=$((ERRORS + 1))
            MESSAGES+=("$file: check failed")
            # Capture error messages
            while IFS= read -r line; do
                if [ -n "$line" ]; then
                    MESSAGES+=("$file: $line")
                fi
            done <<< "$output"
        fi
    fi
done

echo ""
echo "=== Build Summary ==="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo "Success:  $SUCCESS"

# Write results to JSON file
if [ ${#MESSAGES[@]} -eq 0 ]; then
    cat > "$RESULTS_FILE" << EOF
{
  "success": $SUCCESS,
  "errors": $ERRORS,
  "warnings": $WARNINGS,
  "messages": []
}
EOF
else
    # Build messages array
    MESSAGES_JSON="["
    for i in "${!MESSAGES[@]}"; do
        if [ $i -gt 0 ]; then
            MESSAGES_JSON+=","
        fi
        # Escape quotes in message
        escaped=$(echo "${MESSAGES[$i]}" | sed 's/"/\\"/g')
        MESSAGES_JSON+="\"$escaped\""
    done
    MESSAGES_JSON+="]"

    cat > "$RESULTS_FILE" << EOF
{
  "success": $SUCCESS,
  "errors": $ERRORS,
  "warnings": $WARNINGS,
  "messages": $MESSAGES_JSON
}
EOF
fi

echo ""
echo "Results written to $RESULTS_FILE"

# Exit with failure if any errors
[ "$SUCCESS" = true ]
