---
name: project-update
description: Generate a comprehensive project status update based on git commits (REQUIRED: specify date)
allowed-tools: Bash, Read
---

# Project Update

Generate a comprehensive project status update based on git commits.

**IMPORTANT**: This command REQUIRES a date argument. You must specify which date to analyze.

Arguments: $ARGUMENTS

## Instructions

1. **Determine the date (REQUIRED):**
   - A date argument is REQUIRED (e.g., "friday", "november 14", "last week", "today")
   - Only analyze commits made ON the specified date, not commits from previous days
   - Use the exact date boundaries (00:00 to 23:59) for the specified day

2. **Analyze git commits:**
   - Retrieve all commits in the specified date range using `git log`
   - For merged pull requests, analyze all commits included in the PR
   - Get commit statistics (files changed, insertions, deletions)
   - Review commit messages to categorize changes as features, fixes, or miscellaneous

3. **Generate output in BOTH formats:**

**CONCISE FORMAT** (for quick updates):

```
Summary

[2-4 line concise overview of the work completed, focusing on the main feature/component and its status]

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

**DETAILED FORMAT** (for comprehensive documentation):

```
Summary

[2-4 sentence paragraph describing the overall work completed. Include what was implemented, key capabilities added, and any important notes about completion status or known issues. Be specific about the feature/component worked on.]

Features

[Feature Name] - [Detailed description of the feature, what it does, how it works, technical details, UI/UX elements]

[Feature Name] - [Description...]

Fixes

[Fix Name] - [Detailed explanation of what bug was fixed, why it occurred, and how it was resolved. Include technical details about the solution.]

[Fix Name] - [Description...]

Miscellaneous

[Change Description] - [Details about refactoring, architecture changes, code organization, naming changes, etc.]

[Change Description] - [Details...]
```

4. **Formatting rules:**
   - DO NOT use emojis or special characters
   - **Concise format**: Use simple bullet points (single dash) with brief descriptions (1 line each)
   - **Detailed format**: Use **bold** for names (before dash), regular text for descriptions (after dash)
   - **Detailed format**: Include technical details like file paths, method names, specific values
   - **Detailed format**: Mention specific UI elements, data structures, and architectural patterns
   - **Detailed format**: For fixes, explain the root cause and solution approach

5. **Content guidelines:**
   - **Summary**:
     - Concise: 2-4 lines maximum, focus on main feature and status
     - Detailed: 2-4 sentences with key capabilities and completion notes
   - **Features**: New capabilities, UI components, user-facing functionality, data handling
   - **Fixes**: Bug fixes (concise: what was fixed, detailed: root cause and solution)
   - **Miscellaneous**: Refactoring, architecture changes, code organization, naming improvements, navigation patterns, dependency management

6. **Categories:**
   - Categorize commits based on their prefixes:
     - `feat:`, `feat(...)` → Features
     - `fix:`, `fix(...)` → Fixes
     - `refactor:`, `refactor(...)` → Miscellaneous
     - `build:`, `chore:`, UI changes → Miscellaneous as appropriate
