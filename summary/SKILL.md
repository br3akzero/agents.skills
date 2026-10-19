---
name: summary
description: Generate a comprehensive project status update based on git commits. Requires a date argument
allowed-tools: Bash, Read
---

# Project Update

Generate a comprehensive project status update based on git commits (do not mention relevant git commits nor the metadata about git). Relies on conventional commit prefixes (`feat:`, `fix:`, `refactor:`, etc.) to categorize changes.

**IMPORTANT**: This command REQUIRES a date argument. If no date is provided, output "Error: no date specified" and exit immediately.

Arguments: $ARGUMENTS

## Instructions

1. **Determine the date (REQUIRED):** A date argument is REQUIRED (e.g., "friday", "last week", "today"). Only analyze commits within that date's boundaries (00:00-23:59).

2. **Analyze git commits:** Retrieve all commits in the date range with `git log`. Include commits from merged PRs. Get stats (files changed, insertions, deletions) and categorize by commit prefix.

3. **Generate output:**

```
Summary

[2-4 sentence paragraph describing the overall work completed. Include what was implemented, key capabilities added, and any important notes about completion status or known issues. Be specific about the feature/component worked on.]

Features
- [Feature name with brief description]
- [Feature name with brief description]

Fixes
- [Bug fix with brief explanation]
- [Bug fix with brief explanation]

Miscellaneous
- [Change description]
- [Change description]
```

4. **Rules:**
   - No emojis or special characters. Simple bullet points, one line each.
   - Use plain English. Avoid words like "scaffolded", "bootstrapped", "orchestrated", "leveraged", "utilized", "facilitated". Prefer "set up", "built", "uses", "started", "added". Short words, clear sentences.
   - Categorize by prefix: `feat:` -> Features, `fix:` -> Fixes, `refactor:`/`build:`/`chore:` -> Miscellaneous.
   - If a section (Features, Fixes, Miscellaneous) has no entries for the given date, state "None" under that section header instead of omitting it.
   - Do not mention git metadata such as number of lines changed, number of commits, name of branches, etc...
