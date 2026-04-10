---
name: commit
description: Commit tracked and untracked changes in the project. Use conventional commits syntax. Use multiple commits where needed.
allowed-tools: Bash, Read, Glob, Grep
---

# Commit

Commit tracked and untracked changes in the project using conventional commits syntax.

## Instructions

1. Run `git status` to see all tracked and untracked changes
2. Run `git diff` to review the actual changes
3. Run `git log --oneline -5` to see recent commit style
4. Group related changes logically - use multiple commits if changes are unrelated
5. Write commit messages following conventional commits:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for code refactoring
   - `chore:` for maintenance tasks
   - `docs:` for documentation
   - `style:` for formatting changes
   - `test:` for test changes
   - Use scope when applicable: `feat(auth):`, `fix(api):`

## Commit Message Format

- First line: concise summary explaining exactly what the commit adds (50 chars ideal, 72 max)
- Blank line
- Body: detailed explanation if needed (wrap at 72 chars)
- Be detailed but keep the first line concise

## Rules

- DO NOT mention AI assistance in commit messages
- DO NOT add Co-Authored-By lines
- Stage only related files together
- Review changes before committing
