# Commit Conventions

All commits MUST follow the Conventional Commits format.

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style (formatting, no code change) |
| `refactor` | Code refactoring |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |

## Rules

- Description in imperative mood: "add" not "added"
- No period at the end of the description
- Max 72 characters for description line
- Max 100 characters for body lines
- Scope is optional but recommended for large codebases
- Body explains WHAT and WHY, not HOW
- Use `BREAKING CHANGE:` footer for incompatible changes
- Reference issues: `Refs: #123`, `Closes: #456`

## Examples

```
feat(auth): add JWT refresh token rotation

Implement automatic token refresh when access token expires.
The refresh token is rotated on each use for security.

Refs: #123
```

```
fix(api): resolve null pointer in user endpoint

The user endpoint crashed when querying for a deleted user.
Added null check before accessing user properties.

Closes: #456
```

```
feat!: change user ID from int to UUID

BREAKING CHANGE: User IDs are now UUIDs instead of integers.
All API responses and database schemas updated.

Migration: Run `npm run db:migrate` before deploying.
```

## What NOT to Commit

- Merge commits (use rebase or squash)
- "WIP" or "fix" as commit messages
- Multiple unrelated changes in one commit
- Secrets, keys, or credentials
- Generated files that should be in .gitignore
- node_modules, dist, build artifacts
