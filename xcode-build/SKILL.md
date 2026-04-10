---
name: xcode-build
description: Build an iOS/macOS app using xcodebuild. Use when the user wants to compile, build, or check for build errors.
allowed-tools: Bash, Read, AskUserQuestion
---

# Xcode Build

Build an Xcode project or workspace. Output is split into digestible log files.

## Usage

- `/xcode-build` - Build (will prompt for scheme)
- `/xcode-build 18` - Build for iOS 18 simulator
- `/xcode-build 26` - Build for iOS 26 simulator

Arguments: $ARGUMENTS

## Instructions

1. Detect the project/workspace in the current directory:
```bash
# Find xcworkspace (preferred) or xcodeproj
WORKSPACE=$(ls -d *.xcworkspace 2>/dev/null | head -1)
PROJECT=$(ls -d *.xcodeproj 2>/dev/null | head -1)
```

2. Run the build script with version and scheme:
```bash
~/.config/opencode/skills/xcode-build/build.sh [version] <scheme>
```

Examples:
- `~/.config/opencode/skills/xcode-build/build.sh "" Project` (default destination)
- `~/.config/opencode/skills/xcode-build/build.sh 18 Project` (iOS 18)
- `~/.config/opencode/skills/xcode-build/build.sh 26 Project` (iOS 26)

If scheme is not provided, the script will list available schemes and exit.

3. The script outputs a directory path. Read logs in this order:

### Step 1: Check Summary.log
Read `{output_dir}/Summary.log` first to get the build status and summary.

### Step 2: Handle Based on Status

**If BUILD FAILED:**
- Read `{output_dir}/Errors.log`
- Explain what caused the build failure
- Stop here (do not proceed to warnings)

**If BUILD SUCCEEDED:**
- Tell the user the build succeeded
- Report error/warning counts from Summary.log
- Ask user if they want to see the warnings (if warning count > 0)
- If yes, read `{output_dir}/Warnings.log` and summarize

### Step 3: Raw.log (Optional)
Only read `{output_dir}/Raw.log` if:
- User explicitly requests full build output
- You need additional information to diagnose an issue

## Output Directory Structure

```
{project_dir}/.agents/builds/{prefix}_{timestamp}/
├── Summary.log    # Build status + summary (read first)
├── Errors.log     # Only errors (read if build failed)
├── Warnings.log   # Only warnings (read if user wants)
└── Raw.log        # Full unfiltered build output (read if needed)
```
