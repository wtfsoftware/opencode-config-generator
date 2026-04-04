# Skills Registry

Complete catalog of all available skills for opencode.

**Total: 25 skills** across 10 categories.

---

## Frontend (6)

| Skill | Description |
|-------|-------------|
| [`react-master`](skills/react-master/SKILL.md) | React hooks, components, state management, performance optimization, accessibility, error boundaries |
| [`nextjs-master`](skills/nextjs-master/SKILL.md) | App Router, SSR/SSG/ISR, caching strategies, API routes, middleware, image optimization |
| [`ui-design-master`](skills/ui-design-master/SKILL.md) | Visual hierarchy, layout systems, typography, color theory, accessibility, responsive design, micro-interactions |
| [`web-performance-master`](skills/web-performance-master/SKILL.md) | Core Web Vitals (LCP, INP, CLS), bundle optimization, code splitting, CDN, caching, measurement |
| [`web-security-master`](skills/web-security-master/SKILL.md) | CSP, XSS prevention, CSRF protection, secure cookies, SRI, HTTPS, security headers |
| [`mobile-master`](skills/mobile-master/SKILL.md) | React Native architecture, navigation, native modules, offline support, push notifications, app store deployment |

## Language (4)

| Skill | Description |
|-------|-------------|
| [`typescript-master`](skills/typescript-master/SKILL.md) | Generics, utility types, type guards, discriminated unions, strict mode, common pitfalls |
| [`python-master`](skills/python-master/SKILL.md) | Type hints, async/await, dataclasses, Pydantic, pytest, packaging, PEP 8 |
| [`go-master`](skills/go-master/SKILL.md) | Go idioms, interfaces, goroutines, channels, context, error handling, HTTP servers |
| [`rust-master`](skills/rust-master/SKILL.md) | Ownership, borrowing, lifetimes, traits, error handling, smart pointers, async, cargo |

## Backend (4)

| Skill | Description |
|-------|-------------|
| [`api-design-master`](skills/api-design-master/SKILL.md) | RESTful design, HTTP methods/status codes, pagination, versioning, rate limiting, OpenAPI, webhooks |
| [`database-master`](skills/database-master/SKILL.md) | Schema design, normalization, indexing strategies, query optimization, migrations, connection pooling |
| [`security-master`](skills/security-master/SKILL.md) | OWASP Top 10, authentication (JWT, OAuth2), authorization (RBAC, ABAC), input validation, encryption |
| [`data-engineering-master`](skills/data-engineering-master/SKILL.md) | ETL/ELT, Apache Spark, Airflow, data modeling, streaming (Kafka), CDC, data quality, modern data stack |

## DevOps (5)

| Skill | Description |
|-------|-------------|
| [`docker-master`](skills/docker-master/SKILL.md) | Dockerfile best practices, multi-stage builds, layer caching, docker-compose, security, optimization |
| [`ci-cd-master`](skills/ci-cd-master/SKILL.md) | GitHub Actions, caching strategies, deployment patterns (blue-green, canary), environments, secrets |
| [`kubernetes-master`](skills/kubernetes-master/SKILL.md) | Pods, deployments, services, Helm, operators, networking, RBAC, GitOps (ArgoCD), troubleshooting |
| [`cloud-aws-master`](skills/cloud-aws-master/SKILL.md) | EC2, S3, Lambda, DynamoDB, IAM, VPC, CloudFormation, CDK, cost optimization, serverless patterns |
| [`monitoring-master`](skills/monitoring-master/SKILL.md) | Logs/metrics/traces, SLO/SLI, error budgets, multi-window burn rate alerting, Grafana, Prometheus, incident response |

## Architecture (1)

| Skill | Description |
|-------|-------------|
| [`microservices-master`](skills/microservices-master/SKILL.md) | Service decomposition, saga pattern, API gateway, event-driven architecture, service mesh, distributed tracing |

## Testing (1)

| Skill | Description |
|-------|-------------|
| [`testing-master`](skills/testing-master/SKILL.md) | Testing pyramid, TDD, mocking strategies, E2E (Playwright), coverage, CI test optimization, flaky tests |

## Collaboration (2)

| Skill | Description |
|-------|-------------|
| [`code-review-master`](skills/code-review-master/SKILL.md) | Review checklists, code smells, refactoring patterns, constructive feedback, PR best practices |
| [`git-master`](skills/git-master/SKILL.md) | Workflows (GitHub Flow, trunk-based), rebasing, bisect, hooks, submodules, troubleshooting |

## Documentation (1)

| Skill | Description |
|-------|-------------|
| [`docs-master`](skills/docs-master/SKILL.md) | README structure, API documentation, ADRs, changelog, contributing guides, inline docs, Mermaid diagrams |

## Game Development (1)

| Skill | Description |
|-------|-------------|
| [`game-dev-master`](skills/game-dev-master/SKILL.md) | Game loop, ECS architecture, physics/collision, AI (state machines, behavior trees, A*), asset management, optimization |

---

## Quick Install

```bash
# Install all skills
./install-skills.sh --all

# Install by category
./install-skills.sh --category frontend
./install-skills.sh --category devops
./install-skills.sh --category backend

# Install specific skills
./install-skills.sh --skill react-master --skill typescript-master

# Interactive mode
./install-skills.sh

# Preview without installing
./install-skills.sh --dry-run --all
```

## Categories Summary

| Category | Count | Skills |
|----------|-------|--------|
| Frontend | 6 | react, nextjs, ui-design, web-performance, web-security, mobile |
| Language | 4 | typescript, python, go, rust |
| Backend | 4 | api-design, database, security, data-engineering |
| DevOps | 5 | docker, ci-cd, kubernetes, cloud-aws, monitoring |
| Architecture | 1 | microservices |
| Testing | 1 | testing |
| Collaboration | 2 | code-review, git |
| Documentation | 1 | docs |
| Game Development | 1 | game-dev |
