---
name: swift-test
description: Run Swift package tests using swift test. Use when the user wants to run tests, check test results, or verify test passes.
allowed-tools: Bash, Read
---

# Swift Test

Run tests for a Swift package. Output is split into digestible log files.

## Usage

- `/swift-test` - Run all tests
- `/swift-test FilterName` - Run tests matching a filter

Arguments: $ARGUMENTS

## Instructions

1. Verify a `Package.swift` exists in the current directory.

2. Run the test script:
```bash
~/.claude/skills/swift-test/test.sh [filter]
```

Examples:
- `~/.claude/skills/swift-test/test.sh` (all tests)
- `~/.claude/skills/swift-test/test.sh DatabaseTests` (filtered)

3. The script outputs a directory path. Read logs in this order:

### Step 1: Check Summary.log
Read `{output_dir}/Summary.log` first to get the test status and summary.

### Step 2: Handle Based on Status

**If TEST STATUS: BUILD FAILED:**
- Read `{output_dir}/Errors.log`
- Explain what caused the build failure
- Stop here

**If TEST STATUS: FAILED:**
- Read `{output_dir}/Failures.log`
- Explain which tests failed and why
- If more context is needed, read `{output_dir}/Raw.log`

**If TEST STATUS: PASSED:**
- Tell the user all tests passed
- Report counts from Summary.log
- Ask user if they want to see warnings (if warning count > 0)

### Step 3: Raw.log (Optional)
Only read `{output_dir}/Raw.log` if:
- User explicitly requests full test output
- You need additional context to diagnose a failure

## Output Directory Structure

```
{project_dir}/Agents/Tests/{prefix}_{timestamp}/
├── Summary.log    # Test status + counts (read first)
├── Passed.log     # Passed test lines
├── Failures.log   # Failed test lines (read if tests failed)
├── Errors.log     # Build errors (read if build failed)
├── Warnings.log   # Warnings (read if user wants)
└── Raw.log        # Full unfiltered test output (read if needed)
```
