#!/bin/bash

# Build Log Minifier
# Processes xcodebuild output and splits into digestible log files
#
# Usage: xcodebuild ... 2>&1 | minify-build.sh <prefix>
# Example: xcodebuild ... 2>&1 | minify-build.sh "build_ios18"
#
# Creates: Agents/Builds/{prefix}_{timestamp}/
#   - Raw.log       - Full unfiltered build output
#   - Errors.log    - Only errors (empty if none)
#   - Warnings.log  - Only warnings (empty if none)
#   - Summary.log   - Build result summary

set -e

# Setup
PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/Agents/Builds"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PREFIX="${1:-build}"
OUTPUT_DIR="$BUILD_DIR/${PREFIX}_${TIMESTAMP}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# 1. Raw.log - Full unfiltered build output
cat > "$OUTPUT_DIR/Raw.log"

# 2. Errors.log - Only compiler/linker errors (excludes xcodebuild warnings)
grep -E '( error:|^error:|fatal error|undefined symbol|^ld: |clang: error)' "$OUTPUT_DIR/Raw.log" \
    | grep -v "xcodebuild: WARNING" \
    | sed '/^$/d' \
    > "$OUTPUT_DIR/Errors.log" 2>/dev/null || touch "$OUTPUT_DIR/Errors.log"

# 3. Warnings.log - Only SwiftLint/compiler warnings (excludes xcodebuild meta-warnings)
grep -E '( warning:|^warning:)' "$OUTPUT_DIR/Raw.log" \
    | grep -v "xcodebuild: WARNING" \
    | sed '/^$/d' \
    > "$OUTPUT_DIR/Warnings.log" 2>/dev/null || touch "$OUTPUT_DIR/Warnings.log"

# 4. Summary.log - Build result summary
{
    # Extract build result
    if grep -q "BUILD SUCCEEDED" "$OUTPUT_DIR/Raw.log"; then
        echo "BUILD STATUS: SUCCESS"
        echo ""
        echo "Build completed successfully."
    elif grep -q "BUILD FAILED" "$OUTPUT_DIR/Raw.log"; then
        echo "BUILD STATUS: FAILED"
        echo ""
        echo "Build failed. Check Errors.log for details."
    else
        echo "BUILD STATUS: UNKNOWN"
        echo ""
        echo "Could not determine build status."
    fi

    echo ""

    # Count errors and warnings
    ERROR_COUNT=$(wc -l < "$OUTPUT_DIR/Errors.log" | tr -d ' ')
    WARNING_COUNT=$(wc -l < "$OUTPUT_DIR/Warnings.log" | tr -d ' ')

    echo "SUMMARY:"
    echo "  Errors:   $ERROR_COUNT"
    echo "  Warnings: $WARNING_COUNT"

    # List error files if any
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo ""
        echo "FILES WITH ERRORS:"
        grep -oE '[^ ]+\.(swift|m|mm|c|cpp|h):[0-9]+:[0-9]+' "$OUTPUT_DIR/Errors.log" \
            | cut -d: -f1 \
            | sort -u \
            | while read -r file; do
                echo "  - $(basename "$file")"
            done
    fi
} > "$OUTPUT_DIR/Summary.log"

# Output the directory path for the agent to use
echo "Build logs saved to: $OUTPUT_DIR"
