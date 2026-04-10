---
name: swift-build
description: Build a Swift package using swift build. Use when the user wants to compile, build, or check for build errors in a Swift package.
allowed-tools: Bash, Read
---

# Swift Build

Build a Swift package. Output is split into digestible log files.

## Usage

- `/swift-build` - Build the package
- `/swift-build release` - Build in release configuration

Arguments: $ARGUMENTS

## Instructions

1. Verify a `Package.swift` exists in the current directory.

2. Run the build script:
```bash
~/.config/opencode/skills/swift-build/build.sh [configuration]
```

Examples:
- `~/.config/opencode/skills/swift-build/build.sh` (debug, default)
- `~/.config/opencode/skills/swift-build/build.sh release` (release)

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
{project_dir}/Agents/Builds/{prefix}_{timestamp}/
├── Summary.log    # Build status + summary (read first)
├── Errors.log     # Only errors (read if build failed)
├── Warnings.log   # Only warnings (read if user wants)
└── Raw.log        # Full unfiltered build output (read if needed)
```
