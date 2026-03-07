#!/bin/bash

# Generic Xcode Build Script
# Builds the project/workspace in the current directory and saves minified output
#
# Usage:
#   ./build.sh          - Build for default destination
#   ./build.sh 18       - Build for iOS 18 simulator
#   ./build.sh 26       - Build for iOS 26 simulator

set -e

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
MINIFY_SCRIPT="$SCRIPT_DIR/minify-build.sh"

# Auto-detect project/workspace
WORKSPACE=$(ls -d "$PROJECT_ROOT"/*.xcworkspace 2>/dev/null | head -1)
PROJECT=$(ls -d "$PROJECT_ROOT"/*.xcodeproj 2>/dev/null | head -1)

if [ -n "$WORKSPACE" ]; then
    BUILD_TARGET="-workspace $(basename "$WORKSPACE")"
    PROJECT_NAME=$(basename "$WORKSPACE" .xcworkspace)
elif [ -n "$PROJECT" ]; then
    BUILD_TARGET="-project $(basename "$PROJECT")"
    PROJECT_NAME=$(basename "$PROJECT" .xcodeproj)
else
    echo "Error: No .xcworkspace or .xcodeproj found in current directory"
    exit 1
fi

# Get scheme from second argument or prompt
SCHEME="${2:-}"

if [ -z "$SCHEME" ]; then
    echo "Available schemes:"
    xcodebuild -list $BUILD_TARGET 2>/dev/null | awk '/Schemes:/{found=1; next} found && NF{print "  - " $1}'
    echo ""
    echo "ERROR: No scheme specified. Usage: build.sh [version] <scheme>"
    echo "Example: build.sh 26 Fishbyte"
    exit 1
fi

# Parse optional iOS version argument
IOS_VERSION="${1:-}"

# Configure build based on arguments
if [ -z "$IOS_VERSION" ]; then
    DESTINATION=""
    PREFIX="build"
elif [ "$IOS_VERSION" = "18" ]; then
    DESTINATION="-destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5'"
    PREFIX="build_ios18"
elif [ "$IOS_VERSION" = "26" ]; then
    DESTINATION="-destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'"
    PREFIX="build_ios26"
else
    echo "Error: Unsupported iOS version '$IOS_VERSION'. Use 18 or 26."
    exit 1
fi

# Run build and pipe to shared minifier
cd "$PROJECT_ROOT"
if [ -z "$DESTINATION" ]; then
    xcodebuild -scheme "$SCHEME" $BUILD_TARGET build 2>&1 \
        | "$MINIFY_SCRIPT" "$PREFIX"
else
    eval xcodebuild -scheme "$SCHEME" $BUILD_TARGET $DESTINATION build 2>&1 \
        | "$MINIFY_SCRIPT" "$PREFIX"
fi
