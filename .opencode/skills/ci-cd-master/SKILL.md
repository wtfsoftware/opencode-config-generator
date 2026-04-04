---
name: ci-cd-master
description: Build reliable CI/CD pipelines with GitHub Actions, caching strategies, deployment patterns, and environment management. Covers monorepo optimization, branch protection, and release automation.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: devops
  category: devops
---

# CI/CD Master

## What I Do

I help build fast, reliable CI/CD pipelines that catch bugs early and deploy with confidence. I optimize build times, implement deployment strategies, and ensure reproducible, secure releases.

## GitHub Actions Fundamentals

### Workflow Structure
```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# Prevent concurrent deployments
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test -- --coverage
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist/
```

### Event Triggers

**Push/PR**
```yaml
on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
    branches: [main]
    paths:
      - 'src/**'
      - 'package.json'
```

**Scheduled**
```yaml
on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6 AM UTC
```

**Manual Dispatch**
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deploy environment'
        required: true
        default: 'staging'
        type: choice
        options: [staging, production]
```

**Reusable Workflows**
```yaml
# .github/workflows/test.yml (reusable)
on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
```

## Caching Strategies

### Dependency Caching
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm  # or yarn, pnpm

# Manual cache for more control
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Build Cache
```yaml
# TypeScript build cache
- uses: actions/cache@v4
  with:
    path: .tsbuildinfo
    key: ${{ runner.os }}-ts-${{ hashFiles('tsconfig.json') }}-${{ github.sha }}
    restore-keys: ${{ runner.os }}-ts-${{ hashFiles('tsconfig.json') }}-

# Next.js cache
- uses: actions/cache@v4
  with:
    path: |
      ${{ github.workspace }}/.next/cache
    key: ${{ runner.os }}-nextjs-${{ hashFiles('package-lock.json') }}-${{ hashFiles('**/*.js', '**/*.jsx', '**/*.ts', '**/*.tsx') }}
```

### Docker Layer Cache
```yaml
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Cache Key Strategy
```
key: {os}-{package-manager}-{lockfile-hash}
restore-keys: {os}-{package-manager}-
```

## Test Optimization

### Parallel Test Execution
```yaml
test:
  strategy:
    matrix:
      shard: [1, 2, 3, 4]
    fail-fast: false
  runs-on: ubuntu-latest
  steps:
    - run: npm test -- --shard=${{ matrix.shard }}/${{ strategy.job-total }}
```

### Test Matrix
```yaml
test:
  strategy:
    matrix:
      node-version: [18, 20, 22]
      os: [ubuntu-latest, windows-latest]
    fail-fast: false
  runs-on: ${{ matrix.os }}
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
```

### Job Dependencies
```yaml
jobs:
  lint:
    # Runs first
  test:
    needs: lint
    # Runs after lint passes
  build:
    needs: [lint, test]
    # Runs after both lint and test pass
  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    # Runs only on main branch after build
```

## Branch Protection

### Required Checks
```yaml
# In GitHub repo settings:
# Settings > Branches > Branch protection rules
# - Require status checks to pass before merging
# - Require branches to be up to date before merging
# - Require pull request reviews (min 1)
# - Require conversation resolution
# - Include administrators
```

### Status Check Names
```yaml
# Reference jobs by exact name in branch protection
required-status-checks:
  - "lint"
  - "test (1)"
  - "test (2)"
  - "build"
```

## Deployment Strategies

### Blue-Green Deployment
```yaml
deploy:
  runs-on: ubuntu-latest
  steps:
    - name: Deploy to green environment
      run: |
        docker build -t myapp:${{ github.sha }} .
        docker tag myapp:${{ github.sha }} myapp:green
        docker-compose up -d green

    - name: Health check
      run: curl -f http://green:3000/health || exit 1

    - name: Switch traffic to green
      run: |
        nginx -s reload  # Update upstream to point to green

    - name: Tear down blue
      run: docker-compose stop blue
```

### Canary Deployment
```yaml
deploy-canary:
  runs-on: ubuntu-latest
  steps:
    - name: Deploy canary (10% traffic)
      run: |
        kubectl set image deployment/myapp app=myapp:${{ github.sha }}
        kubectl scale deployment/myapp-canary --replicas=1
        kubectl scale deployment/myapp --replicas=9

    - name: Monitor for 15 minutes
      run: sleep 900

    - name: Check error rates
      run: |
        ERROR_RATE=$(curl -s http://monitoring/api/error-rate?service=myapp-canary)
        if (( $(echo "$ERROR_RATE > 1.0" | bc -l) )); then
          echo "Error rate too high, rolling back"
          kubectl rollout undo deployment/myapp-canary
          exit 1
        fi

    - name: Full rollout
      run: kubectl set image deployment/myapp app=myapp:${{ github.sha }}
```

### Rolling Deployment
```yaml
deploy:
  steps:
    - name: Deploy with rolling update
      run: |
        kubectl set image deployment/myapp app=myapp:${{ github.sha }}
        kubectl rollout status deployment/myapp --timeout=300s
```

## Environment Management

### GitHub Environments
```yaml
deploy-staging:
  runs-on: ubuntu-latest
  environment: staging
  steps:
    - run: echo "Deploying to staging"

deploy-production:
  runs-on: ubuntu-latest
  environment:
    name: production
    url: https://myapp.com
  steps:
    - run: echo "Deploying to production"
```

### Environment Variables
```yaml
jobs:
  deploy:
    environment: production
    env:
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
      API_KEY: ${{ secrets.API_KEY }}
    steps:
      - run: echo "Deploying with secrets"
```

### Environment Promotion
```yaml
# staging deploys automatically on main merge
deploy-staging:
  if: github.ref == 'refs/heads/main'
  environment: staging

# production requires manual approval
deploy-production:
  if: github.ref == 'refs/heads/main'
  needs: deploy-staging
  environment:
    name: production  # Has required reviewers
```

## Secrets Management

### GitHub Secrets
```yaml
steps:
  - run: echo "$SECRET"
    env:
      SECRET: ${{ secrets.MY_SECRET }}
```

### Secrets Best Practices
- Never echo or log secrets
- Use environment-level secrets for deployment keys
- Rotate secrets regularly
- Use OIDC for cloud provider access (no long-lived keys)
- Use secret scanning to detect leaked secrets

### OIDC for Cloud Providers
```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789:role/github-actions
      aws-region: us-east-1
```

## Monorepo CI

### Path Filtering
```yaml
on:
  push:
    paths:
      - 'packages/api/**'
      - 'packages/shared/**'
      - 'package.json'
```

### Changed Files Detection
```yaml
- uses: dorny/paths-filter@v3
  id: filter
  with:
    filters: |
      api:
        - 'packages/api/**'
      web:
        - 'packages/web/**'
      shared:
        - 'packages/shared/**'

- if: steps.filter.outputs.api == 'true'
  run: npm run build --workspace=packages/api
```

### Nx/Turborepo Affected
```yaml
- run: npx nx affected -t lint test build --base=origin/main~1 --head=HEAD
```

## Release Automation

### Semantic Versioning
```yaml
release:
  runs-on: ubuntu-latest
  if: startsWith(github.ref, 'refs/tags/v')
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
    - run: npm ci
    - run: npm run build

    - name: Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        generate_release_notes: true
        files: |
          dist/*.js
          dist/*.map
```

### Auto Versioning
```yaml
version:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        token: ${{ secrets.GH_TOKEN }}

    - name: Semantic Release
      uses: cycjimmy/semantic-release/action@v4
      with:
        extra_plugins: |
          @semantic-release/changelog
          @semantic-release/git
      env:
        GITHUB_TOKEN: ${{ secrets.GH_TOKEN }}
        NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Changelog Generation
```yaml
- name: Generate changelog
  run: |
    npx changelog-parser CHANGELOG.md > release-notes.md

- name: Create Release
  uses: softprops/action-gh-release@v1
  with:
    body_path: release-notes.md
```

## Pipeline Status & Reporting

### Status Badges
```markdown
[![CI](https://github.com/user/repo/actions/workflows/ci.yml/badge.svg)](https://github.com/user/repo/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/user/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/user/repo)
```

### Slack/Discord Notifications
```yaml
- name: Notify on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "❌ CI failed: ${{ github.repository }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*CI Failed*\nRepo: ${{ github.repository }}\nBranch: ${{ github.ref_name }}\n<${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View logs>"
            }
          }
        ]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## Performance Optimization

### Fast Pipeline Tips
- Cache dependencies aggressively
- Use `actions/checkout@v4` with `fetch-depth: 1` for PRs
- Run independent jobs in parallel
- Use `needs` to create dependency chains, not sequential steps
- Skip CI on docs-only changes
- Use self-hosted runners for faster execution
- Profile pipeline to find bottlenecks

### Skip CI on Docs Changes
```yaml
on:
  push:
    paths-ignore:
      - '**/*.md'
      - 'docs/**'
      - '.github/ISSUE_TEMPLATE/**'
```

## When to Use Me

Use this skill when:
- Setting up GitHub Actions workflows
- Optimizing CI build times
- Implementing deployment pipelines
- Configuring branch protection
- Setting up environment management
- Automating releases and versioning
- Configuring monorepo CI
- Adding notifications and reporting

## Quality Checklist

- [ ] Dependencies cached between runs
- [ ] Tests run in parallel when possible
- [ ] Deployments have health checks
- [ ] Secrets never logged or exposed
- [ ] Branch protection requires status checks
- [ ] Pipeline fails fast on errors
- [ ] Artifacts uploaded for debugging
- [ ] Environments have proper access controls
- [ ] Rollback strategy defined
- [ ] Pipeline completes in under 10 minutes
- [ ] Notifications configured for failures
