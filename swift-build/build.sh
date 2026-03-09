#!/bin/bash

# Swift Package Build Script
# Builds the Swift package in the current directory and saves minified output
#
# Usage:
#   ./build.sh           - Build in debug configuration
#   ./build.sh release   - Build in release configuration

set -e

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/Agents/Builds"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Verify Package.swift exists
if [ ! -f "$PROJECT_ROOT/Package.swift" ]; then
    echo "Error: No Package.swift found in current directory"
    exit 1
fi

# Parse configuration argument
CONFIG="${1:-debug}"
if [ "$CONFIG" = "release" ]; then
    BUILD_FLAGS="-c release"
    PREFIX="build_release"
else
    BUILD_FLAGS=""
    PREFIX="build_debug"
fi

OUTPUT_DIR="$BUILD_DIR/${PREFIX}_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# Run swift build and capture output
swift build $BUILD_FLAGS 2>&1 | tee "$OUTPUT_DIR/Raw.log" || true

# Extract errors
grep -E '(error:|fatal error|cannot find|undefined symbol|no such module)' "$OUTPUT_DIR/Raw.log" \
    | sed '/^$/d' \
    > "$OUTPUT_DIR/Errors.log" 2>/dev/null || touch "$OUTPUT_DIR/Errors.log"

# Extract warnings
grep -E '(warning:)' "$OUTPUT_DIR/Raw.log" \
    | sed '/^$/d' \
    > "$OUTPUT_DIR/Warnings.log" 2>/dev/null || touch "$OUTPUT_DIR/Warnings.log"

# Generate summary
{
    if grep -q "Build complete!" "$OUTPUT_DIR/Raw.log"; then
        echo "BUILD STATUS: SUCCESS"
        echo ""
        echo "Build completed successfully."
    elif grep -qE "(error:|build.*error)" "$OUTPUT_DIR/Raw.log"; then
        echo "BUILD STATUS: FAILED"
        echo ""
        echo "Build failed. Check Errors.log for details."
    else
        echo "BUILD STATUS: UNKNOWN"
        echo ""
        echo "Could not determine build status."
    fi

    echo ""

    ERROR_COUNT=$(wc -l < "$OUTPUT_DIR/Errors.log" | tr -d ' ')
    WARNING_COUNT=$(wc -l < "$OUTPUT_DIR/Warnings.log" | tr -d ' ')

    echo "SUMMARY:"
    echo "  Errors:   $ERROR_COUNT"
    echo "  Warnings: $WARNING_COUNT"

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

echo "Build logs saved to: $OUTPUT_DIR"
