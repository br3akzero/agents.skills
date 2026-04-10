# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a private collection of AI agent skills — reusable slash commands for AI coding agents. This repository is symlinked to `~/.config/opencode/skills/`, so any skill added here is automatically available.

## Structure

Each skill lives in its own directory with a `SKILL.md` file and optional supporting scripts:

```
<skill-name>/
├── SKILL.md        # Frontmatter + instructions for the skill
└── *.sh            # Optional shell scripts referenced by the skill
```

## SKILL.md Format

```markdown
---
name: skill-name
description: One-line description shown in the skill picker
allowed-tools: Bash, Read, Glob, ...
---

# Skill Title

Instructions for the agent to follow when this skill is invoked.
```

- `name`: matches the directory name and the `/skill-name` invocation
- `description`: used to decide when to trigger the skill
- `allowed-tools`: whitelist of tools the skill may use

## Adding a New Skill

1. Create a new directory: `mkdir <skill-name>`
2. Add `SKILL.md` with frontmatter and instructions
3. Add any supporting scripts if needed

The skill is immediately available — no install step required.
