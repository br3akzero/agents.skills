#!/bin/bash

# Swift Package Test Script
# Runs tests for the Swift package in the current directory and saves parsed output
#
# Usage:
#   ./test.sh              - Run all tests
#   ./test.sh FilterName   - Run tests matching filter

set -e

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
TEST_DIR="$PROJECT_ROOT/Agents/Tests"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Verify Package.swift exists
if [ ! -f "$PROJECT_ROOT/Package.swift" ]; then
    echo "Error: No Package.swift found in current directory"
    exit 1
fi

# Parse filter argument
FILTER="${1:-}"
if [ -n "$FILTER" ]; then
    TEST_FLAGS="--filter $FILTER"
    PREFIX="test_filtered"
else
    TEST_FLAGS=""
    PREFIX="test_all"
fi

OUTPUT_DIR="$TEST_DIR/${PREFIX}_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# Run swift test and capture output
swift test $TEST_FLAGS 2>&1 | tee "$OUTPUT_DIR/Raw.log" || true

# Extract passed tests
grep -E '^✔' "$OUTPUT_DIR/Raw.log" \
    > "$OUTPUT_DIR/Passed.log" 2>/dev/null || touch "$OUTPUT_DIR/Passed.log"

# Extract failed tests
grep -E '^(✘|✗)' "$OUTPUT_DIR/Raw.log" \
    > "$OUTPUT_DIR/Failures.log" 2>/dev/null || touch "$OUTPUT_DIR/Failures.log"

# Extract build/compile errors (tests may fail to build)
grep -E '(error:|fatal error|cannot find|undefined symbol|no such module)' "$OUTPUT_DIR/Raw.log" \
    | sed '/^$/d' \
    > "$OUTPUT_DIR/Errors.log" 2>/dev/null || touch "$OUTPUT_DIR/Errors.log"

# Extract warnings
grep -E '(warning:)' "$OUTPUT_DIR/Raw.log" \
    | sed '/^$/d' \
    > "$OUTPUT_DIR/Warnings.log" 2>/dev/null || touch "$OUTPUT_DIR/Warnings.log"

# Generate summary
{
    PASSED_COUNT=$(wc -l < "$OUTPUT_DIR/Passed.log" | tr -d ' ')
    FAILED_COUNT=$(wc -l < "$OUTPUT_DIR/Failures.log" | tr -d ' ')
    ERROR_COUNT=$(wc -l < "$OUTPUT_DIR/Errors.log" | tr -d ' ')
    WARNING_COUNT=$(wc -l < "$OUTPUT_DIR/Warnings.log" | tr -d ' ')
    TOTAL_COUNT=$((PASSED_COUNT + FAILED_COUNT))

    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "TEST STATUS: BUILD FAILED"
        echo ""
        echo "Tests failed to compile. Check Errors.log for details."
    elif [ "$FAILED_COUNT" -gt 0 ]; then
        echo "TEST STATUS: FAILED"
        echo ""
        echo "$FAILED_COUNT of $TOTAL_COUNT tests failed. Check Failures.log for details."
    elif [ "$PASSED_COUNT" -gt 0 ]; then
        echo "TEST STATUS: PASSED"
        echo ""
        echo "All $TOTAL_COUNT tests passed."
    else
        echo "TEST STATUS: UNKNOWN"
        echo ""
        echo "Could not determine test results."
    fi

    echo ""
    echo "SUMMARY:"
    echo "  Passed:   $PASSED_COUNT"
    echo "  Failed:   $FAILED_COUNT"
    echo "  Total:    $TOTAL_COUNT"
    echo "  Errors:   $ERROR_COUNT"
    echo "  Warnings: $WARNING_COUNT"

    if [ "$FAILED_COUNT" -gt 0 ]; then
        echo ""
        echo "FAILED TESTS:"
        sed 's/^/  /' "$OUTPUT_DIR/Failures.log"
    fi

    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo ""
        echo "FILES WITH ERRORS:"
        grep -oE '[^ ]+\.swift:[0-9]+:[0-9]+' "$OUTPUT_DIR/Errors.log" \
            | cut -d: -f1 \
            | sort -u \
            | while read -r file; do
                echo "  - $file"
            done
    fi
} > "$OUTPUT_DIR/Summary.log"

echo "Test logs saved to: $OUTPUT_DIR"
