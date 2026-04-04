---
name: git-master
description: Master Git workflows, branching strategies, and collaboration patterns. Covers rebasing, bisect, hooks, troubleshooting, and team workflows.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: fullstack
  category: collaboration
---

# Git Master

## What I Do

I help teams use Git effectively for version control, collaboration, and code management. I ensure clean history, efficient workflows, and proper troubleshooting.

## Workflows

### GitHub Flow (Simple)
```
main ─────────────────────────────────────────────
        \         \         \
         feat/a    feat/b    fix/c
          \         \         \
           PR ──────PR ───────PR
            \         \         \
             merge ─── merge ─── merge

Rules:
- main is always deployable
- Create branch from main for each feature/fix
- Work locally, push frequently
- Open PR for review
- Merge to main after review
- Deploy from main
```

### Trunk-Based Development
```
main ──●──●──●──●──●──●──●──●── (deploy continuously)
        \  \    \
         \  \    ●── fix (merged same day)
          \  ●── feat (merged same day)
           ●── feat (merged same day)

Rules:
- Short-lived branches (hours, not days)
- Feature flags for incomplete features
- Multiple small PRs per day
- Automated testing on every commit
```

### Git Flow (Traditional)
```
main ─────●──────────────────────●── (releases only)
           \                    /
develop ────●──●──●──●──●──────●── (integration branch)
             \   \   \  \     /
              \   \   \  \   /
feat/a ────────●───●  \  \ /
feat/b ────────────●──●  ●──
hotfix ───────────────────●── (from main, to both)
```

### When to Use Which
| Workflow | Team Size | Release Frequency | Complexity |
|----------|-----------|-------------------|------------|
| GitHub Flow | Any | Continuous | Low |
| Trunk-Based | Small-Medium | Multiple/day | Low-Medium |
| Git Flow | Large | Scheduled releases | High |
| Fork Flow | Open source | Variable | Medium |

## Branching Strategy

### Naming Conventions
```
feat/user-authentication
fix/login-crash
hotfix/security-patch
refactor/payment-service
docs/api-documentation
chore/upgrade-dependencies
release/v2.1.0
```

### Branch Protection Rules
```yaml
# GitHub: Settings > Branches > Branch protection
main:
  - Require pull request reviews (min 1)
  - Require status checks to pass
  - Require branches to be up to date
  - Include administrators
  - Require linear history (no merge commits)
  - Require signed commits (optional)
  - Restrict who can push
```

## Rebasing vs Merging

### Merge (Preserves History)
```bash
git merge feature-branch
# Creates a merge commit, preserves branch history
# Good for: Shared branches, tracking feature development

# Result:
# *   Merge commit
# |\
# | * feature commits
# * | main commits
# |/
# * common ancestor
```

### Rebase (Clean History)
```bash
git rebase main
# Rewrites feature branch on top of main
# Good for: Feature branches, clean linear history

# Result:
# * feature commits (replayed on top)
# * main commits
# * common ancestor
```

### Interactive Rebase
```bash
# Last 5 commits
git rebase -i HEAD~5

# Commands:
# pick   — use commit as-is
# reword — use commit but edit message
# edit   — pause for amending
# squash — combine with previous commit
# fixup  — combine, discard message
# drop   — remove commit

# Example: Clean up before PR
# Before:                    After:
# pick: WIP                  fixup: WIP
# pick: Fix typo             fixup: Fix typo
# pick: Actually fix         squash: Fix authentication
# pick: Add tests            pick: Add tests
# pick: Update docs          reword: Update documentation
```

### Golden Rules
```
✅ Rebase your own unpushed branches
✅ Rebase feature branches onto main before merging
✅ NEVER rebase shared/pushed branches (without team agreement)
✅ Merge for shared branches and releases
```

## Bisect

### Finding Bugs
```bash
# Start bisect
git bisect start
git bisect bad                    # Current commit is bad
git bisect good v2.0.0            # This version was good

# Git checks out middle commit
# Test and mark:
git bisect good                   # or git bisect bad

# Repeat until found:
# Bisecting: 3 revisions left
# <commit-hash> is the first bad commit

# Reset when done
git bisect reset
```

### Automated Bisect
```bash
git bisect start
git bisect bad HEAD
git bisect good v2.0.0
git bisect run npm test
# Automatically finds first bad commit
git bisect reset
```

## Hooks

### Pre-Commit Hook
```bash
#!/bin/sh
# .husky/pre-commit

# Run linter
npm run lint

# Run type check
npm run typecheck

# Run tests on changed files
npm test -- --findRelatedChanges $(git diff --cached --name-only)
```

### Commit Message Hook
```bash
#!/bin/sh
# .husky/commit-msg

commit_msg=$(cat "$1")
pattern="^(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .+"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo "Error: Commit message must follow Conventional Commits format"
  echo "Examples:"
  echo "  feat: add user authentication"
  echo "  fix(api): resolve null pointer in user endpoint"
  echo "  docs: update API documentation"
  exit 1
fi
```

### Pre-Push Hook
```bash
#!/bin/sh
# .husky/pre-push

# Run full test suite before pushing
npm test

# Check for secrets
if git diff --cached -U0 | grep -iE "(password|secret|api_key|token)\s*[:=]"; then
  echo "Error: Possible secret detected in commit"
  exit 1
fi
```

## Essential Commands

### Daily Workflow
```bash
# Start new feature
git checkout main && git pull
git checkout -b feat/new-feature

# Work and commit
git add -p                    # Interactive staging
git commit -m "feat: add feature"

# Update from main
git fetch origin
git rebase origin/main

# Push and create PR
git push -u origin feat/new-feature

# After PR merge
git checkout main && git pull
git branch -d feat/new-feature
```

### Undoing Changes
```bash
# Unstage file
git restore --staged file.txt

# Discard local changes
git restore file.txt

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert commit (safe for shared branches)
git revert <commit-hash>

# Amend last commit
git commit --amend

# Remove file from history
git filter-repo --invert-paths --path sensitive-file.txt
```

### Stashing
```bash
# Save current work
git stash push -m "WIP: auth feature"

# List stashes
git stash list

# Apply and keep
git stash apply stash@{0}

# Apply and delete
git stash pop stash@{0}

# Create branch from stash
git stash branch feat/auth stash@{0}
```

### Cherry-Picking
```bash
# Apply specific commit to current branch
git cherry-pick <commit-hash>

# Apply range
git cherry-pick abc123..def456

# Cherry-pick without committing
git cherry-pick -n <commit-hash>
```

## Collaboration

### Code Review Workflow
```bash
# Review someone's PR locally
git fetch origin pull/123/head:pr-123
git checkout pr-123

# Add commits to existing PR
git checkout feat/branch
git commit -m "fix: address review comments"
git push
```

### Resolving Conflicts
```bash
# During rebase or merge
git status                    # See conflicted files
# Edit files to resolve conflicts
git add resolved-file.txt
git rebase --continue         # or git merge --continue

# Abort if too complex
git rebase --abort
git merge --abort
```

### Shared Repository Tips
```bash
# Always pull with rebase for linear history
git config pull.rebase true

# See who changed what
git log --oneline --graph --all
git blame file.txt
git log -p file.txt           # With diffs

# Find when something was introduced
git log -S "functionName"     # Search in code changes
git log -G "regex"            # Search with regex
```

## Submodules and Subtrees

### Submodules
```bash
# Add submodule
git submodule add https://github.com/org/lib.git libs/lib

# Clone with submodules
git clone --recurse-submodules <repo>

# Update submodules
git submodule update --remote

# Submodule pros: Independent versioning, small main repo
# Submodule cons: Complex workflow, detached HEAD confusion
```

### Subtrees
```bash
# Add subtree
git subtree add --prefix=libs/lib https://github.com/org/lib.git main --squash

# Pull updates
git subtree pull --prefix=libs/lib https://github.com/org/lib.git main --squash

# Push changes back
git subtree push --prefix=libs/lib https://github.com/org/lib.git main

# Subtree pros: Simpler than submodules, single repo feel
# Subtree cons: Larger repo, merge conflicts harder
```

## Troubleshooting

### Detached HEAD
```bash
# You're in detached HEAD state
# Option 1: Create branch from here
git checkout -b recovery-branch

# Option 2: Go back to branch
git checkout main
```

### Lost Commits
```bash
# Find lost commit
git reflog

# Recover
git cherry-pick <commit-hash>
# or
git branch recovery <commit-hash>
```

### Large Files
```bash
# Check repo size
git count-objects -vH

# Find large files
git rev-list --objects --all | git cat-file --batch-check | sort -k3 -n -r | head -20

# Use Git LFS for large files
git lfs install
git lfs track "*.psd"
git lfs track "*.mp4"
```

### Cleanup
```bash
# Remove merged branches
git branch --merged | grep -v '\*' | xargs git branch -d

# Garbage collect
git gc --prune=now

# Remove unreachable objects
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

## Performance

### Shallow Clone
```bash
# Clone only recent history
git clone --depth 1 <repo>

# Fetch more history later
git fetch --depth 100

# Unshallow
git fetch --unshallow
```

### Sparse Checkout
```bash
# Clone specific directories
git clone --sparse <repo>
cd repo
git sparse-checkout set dir1 dir2
```

## When to Use Me

Use this skill when:
- Setting up Git workflows for teams
- Resolving complex merge conflicts
- Cleaning up commit history
- Finding bugs with bisect
- Setting up Git hooks
- Managing submodules or subtrees
- Recovering lost commits
- Optimizing large repositories

## Quality Checklist

- [ ] Branch naming convention established and followed
- [ ] Branch protection rules configured for main
- [ ] Conventional Commits format enforced
- [ ] Pre-commit hooks for linting and type checking
- [ ] Feature branches rebased before merging
- [ ] No secrets in git history
- [ ] .gitignore comprehensive
- [ ] Git LFS configured for large files
- [ ] CI runs on every push to main
- [ ] PR template in place
