---
name: docker-master
description: Build optimized, secure Docker images and manage multi-container applications. Covers Dockerfile best practices, multi-stage builds, docker-compose, and production deployment patterns.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: devops
  category: devops
---

# Docker Master

## What I Do

I help create efficient, secure Docker images and orchestrate multi-container applications. I optimize build times, reduce image sizes, and ensure production-ready container configurations.

## Dockerfile Best Practices

### Core Principles
- One process per container
- Use official base images
- Pin image versions (never use `latest` in production)
- Minimize layers — combine RUN commands
- Order layers from least to most frequently changed
- Use `.dockerignore` to exclude unnecessary files

### .dockerignore
```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.*
Dockerfile
docker-compose*.yml
.dockerignore
README.md
LICENSE
.vscode
.idea
coverage
.nyc_output
dist
*.md
```

## Multi-Stage Builds

### Node.js Application
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts
COPY . .
RUN npm run build
RUN npm prune --production

# Stage 2: Production
FROM node:20-alpine AS production
WORKDIR /app

# Add non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist

USER appuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "dist/index.js"]
```

### Go Application
```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/server

FROM scratch
COPY --from=builder /app/server /app/server
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/app/server"]
```

### Python Application
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim AS production
WORKDIR /app
COPY --from=builder /install /usr/local
COPY . .
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
```

## Layer Caching Optimization

### Order Matters
```dockerfile
# Good: Dependencies change less often than source code
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Bad: Any source change invalidates npm ci cache
COPY . .
RUN npm ci
RUN npm run build
```

### Cache Busting
```dockerfile
# Force rebuild of dependencies when lock file changes
COPY package.json package-lock.json ./
RUN npm ci

# Source code changes won't invalidate the npm ci cache
COPY src/ ./src/
COPY tsconfig.json ./
RUN npm run build
```

## Image Size Optimization

### Base Image Size Comparison
| Image              | Size    | Use Case                    |
|--------------------|---------|-----------------------------|
| `node:20`          | ~1GB    | Development, debugging      |
| `node:20-slim`     | ~250MB  | General production          |
| `node:20-alpine`   | ~50MB   | Production (smallest Node)  |
| `distroless/node`  | ~40MB   | Production (minimal, secure)|
| `scratch`          | ~0MB    | Statically compiled binaries|

### Size Reduction Techniques
```dockerfile
# Use slim/alpine variants
FROM node:20-alpine

# Clean package manager cache in same RUN
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Use --production flag for npm
RUN npm ci --only=production && npm cache clean --force

# Use multi-stage builds to exclude build tools
# Use distroless images for minimal attack surface
```

## Security Best Practices

### Non-Root User
```dockerfile
# Debian/Ubuntu
RUN useradd -m -u 1001 appuser
USER appuser

# Alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

### Read-Only Filesystem
```dockerfile
# Run with read-only root filesystem
docker run --read-only --tmpfs /tmp myapp
```

### No Secrets in Image
```dockerfile
# NEVER do this
ENV DB_PASSWORD=secret123

# Use BuildKit secrets
RUN --mount=type=secret,id=db_password \
    export DB_PASSWORD=$(cat /run/secrets/db_password)

# Or pass at runtime
docker run -e DB_PASSWORD=$DB_PASSWORD myapp
```

### Docker BuildKit Secrets
```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./

# Mount npm token as secret for private packages
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm ci

COPY . .
RUN npm run build
```

### Scan Images
```bash
# Scan for vulnerabilities
docker scout cve myapp:latest

# Check for best practices
docker run --rm -i hadolint/hadolint < Dockerfile
```

## Health Checks

```dockerfile
# HTTP health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# TCP health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD nc -z localhost 5432 || exit 1

# Process health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD pg_isready -U postgres || exit 1
```

### Health Check Options
- `--interval`: Time between checks (default: 30s)
- `--timeout`: Max time for check to complete (default: 30s)
- `--start-period`: Grace period for container startup (default: 0s)
- `--retries`: Consecutive failures before unhealthy (default: 3)

## Docker Compose

### Development Setup
```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    command: npm run dev

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: pg_isready -U postgres
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: redis-cli ping
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

### Production Setup
```yaml
services:
  app:
    build:
      context: .
      target: production
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      db:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    healthcheck:
      test: wget -qO- http://localhost:3000/health || exit 1
      interval: 30s
      timeout: 5s
      retries: 3
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    healthcheck:
      test: pg_isready -U ${POSTGRES_USER}
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app

volumes:
  postgres_data:
```

### Network Configuration
```yaml
services:
  app:
    networks:
      - frontend
      - backend
  db:
    networks:
      - backend
  nginx:
    networks:
      - frontend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

## Restart Policies

| Policy              | Behavior                                    |
|---------------------|---------------------------------------------|
| `no`                | Never restart (default)                     |
| `always`            | Always restart, even on manual stop         |
| `unless-stopped`    | Always restart unless manually stopped      |
| `on-failure[:max]`  | Restart only on non-zero exit, max retries  |

## Common Patterns

### Cron Jobs in Docker
```dockerfile
FROM python:3.12-slim
RUN apt-get update && apt-get install -y cron
COPY cronfile /etc/cron.d/myjob
RUN chmod 0644 /etc/cron.d/myjob && crontab /etc/cron.d/myjob
CMD ["cron", "-f"]
```

### Entrypoint Script
```bash
#!/bin/sh
set -e

# Run migrations
npm run db:migrate

# Start application
exec "$@"
```

```dockerfile
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "dist/index.js"]
```

### Build Arguments vs Environment Variables
```dockerfile
# ARG: Available during build only
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# ENV: Available at runtime
ENV PORT=3000

# Build with custom arg
docker build --build-arg NODE_ENV=staging .
```

## Docker in CI/CD

### GitHub Actions
```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: |
      myapp:latest
      myapp:${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
    build-args: |
      NODE_ENV=production
```

## Troubleshooting

### Debug Running Container
```bash
# Exec into container
docker exec -it <container> sh

# View logs
docker logs -f --tail 100 <container>

# Inspect container
docker inspect <container>

# Check image layers
docker history myapp:latest

# Check container resource usage
docker stats
```

### Clean Up
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove everything
docker system prune -a --volumes

# Check disk usage
docker system df
```

## When to Use Me

Use this skill when:
- Writing Dockerfiles for any language
- Setting up docker-compose for development
- Optimizing image size
- Securing container configurations
- Implementing health checks
- Setting up multi-stage builds
- Configuring Docker for CI/CD
- Debugging container issues

## Quality Checklist

- [ ] Base image version is pinned (no `latest`)
- [ ] Multi-stage build used for production
- [ ] Non-root user configured
- [ ] `.dockerignore` file exists and is comprehensive
- [ ] No secrets in image layers
- [ ] Health check defined
- [ ] Layers ordered by change frequency
- [ ] Production dependencies only in final image
- [ ] Image size is minimized
- [ ] Restart policy set appropriately
- [ ] Resource limits configured
- [ ] Logging driver configured with rotation
