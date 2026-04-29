#!/bin/bash

# Generic Xcode Build Script
# Builds the project/workspace in the current directory and saves minified output
#
# Usage:
#   ./build.sh <scheme>                              - Build for default destination
#   ./build.sh <scheme> 18                           - Build for iOS 18 simulator
#   ./build.sh <scheme> 26                           - Build for iOS 26 simulator
#   ./build.sh <scheme> -- <destination>             - Build for custom destination
#
# Destination shortcuts:
#   18   -> platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5
#   26   -> platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4
#
# Custom destination examples:
#   ./build.sh Radio -- 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4'
#   ./build.sh Radio -- 'platform=iOS Simulator,id=EF659659-8797-45B9-AC9F-1943D5AF3C00'
#   ./build.sh Radio -- 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=26.4'
#   ./build.sh Radio -- 'generic/platform=iOS'

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

# Parse arguments
SCHEME=""
IOS_VERSION=""
CUSTOM_DESTINATION=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --)
            shift
            CUSTOM_DESTINATION="$*"
            break
            ;;
        18|26)
            IOS_VERSION="$1"
            shift
            ;;
        *)
            if [ -z "$SCHEME" ]; then
                SCHEME="$1"
            else
                echo "Error: Unexpected argument '$1'"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$SCHEME" ]; then
    echo "Available schemes:"
    xcodebuild -list $BUILD_TARGET 2>/dev/null | awk '/Schemes:/{found=1; next} found && NF{print "  - " $1}'
    echo ""
    echo "ERROR: No scheme specified."
    echo ""
    echo "Usage: build.sh <scheme> [version|-- destination]"
    echo "  build.sh Radio 26"
    echo "  build.sh Radio -- 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4'"
    echo "  build.sh Radio -- 'generic/platform=iOS'"
    exit 1
fi

# Configure destination
if [ -n "$CUSTOM_DESTINATION" ]; then
    DESTINATION="-destination \"$CUSTOM_DESTINATION\""
    PREFIX="build_custom"
elif [ -n "$IOS_VERSION" ]; then
    case "$IOS_VERSION" in
        18)
            DESTINATION="-destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5'"
            PREFIX="build_ios18"
            ;;
        26)
            DESTINATION="-destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4'"
            PREFIX="build_ios26"
            ;;
    esac
else
    DESTINATION=""
    PREFIX="build"
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
