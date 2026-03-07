---
name: xcode-format
description: Format Swift source files using swift-format. Use when the user wants to format code, fix formatting, or apply code style.
allowed-tools: Bash
---

# Xcode Format

Format Swift source files using swift-format.

## Command

```bash
# Format all Swift files in common source directories
swift-format format -i -r .
```

## Instructions

1. Check for common source directories (Source/, Sources/, src/, App/)
2. If a specific directory exists, format that:
   ```bash
   swift-format format -i -r Source/
   ```
3. Otherwise, format from the current directory (excluding build artifacts):
   ```bash
   find . -name "*.swift" -not -path "*/.*" -not -path "*/build/*" -not -path "*/DerivedData/*" | xargs swift-format format -i
   ```
4. Confirm formatting is complete
5. If specific files are requested, adjust the path accordingly
