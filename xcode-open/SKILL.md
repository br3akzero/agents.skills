---
name: xcode-open
description: Open the Xcode project or workspace in the current directory. Use when the user wants to open Xcode, launch the IDE, or open the project.
allowed-tools: Bash
---

# Xcode Open

Open the Xcode project or workspace in the current directory.

## Instructions

1. Detect and open the project/workspace:
```bash
# Prefer workspace over project
WORKSPACE=$(ls -d *.xcworkspace 2>/dev/null | head -1)
PROJECT=$(ls -d *.xcodeproj 2>/dev/null | head -1)

if [ -n "$WORKSPACE" ]; then
    open "$WORKSPACE"
elif [ -n "$PROJECT" ]; then
    open "$PROJECT"
else
    echo "No .xcworkspace or .xcodeproj found in current directory"
fi
```

2. Confirm Xcode has been launched
