---
name: monitoring-master
description: Implement comprehensive observability with logs, metrics, and traces. Covers SLO/SLI, alerting, dashboards, incident response, and the Prometheus/Grafana stack.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: devops
  category: devops
---

# Monitoring Master

## What I Do

I help implement comprehensive observability systems that catch issues before they impact users. I design monitoring strategies based on the three pillars: logs, metrics, and traces.

## Three Pillars of Observability

```
┌─────────────────────────────────────────────────┐
│              OBSERVABILITY                       │
├──────────────┬──────────────┬───────────────────┤
│    LOGS      │   METRICS    │      TRACES       │
│              │              │                   │
│ What happened│ How often    │ Why it happened   │
│              │              │                   │
│ Structured   │ Aggregated   │ Request journey   │
│ text/events  │ numbers      │ across services   │
│              │              │                   │
│ High detail  │ Low storage  │ High cardinality  │
│ High storage │ Fast query   │ Complex setup     │
└──────────────┴──────────────┴───────────────────┘
```

## Logging

### Structured Logging
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: 'user-service',
    environment: process.env.NODE_ENV,
  },
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
  ],
});

// Usage — always structured
logger.info('User created', {
  userId: 'usr_123',
  email: 'user@example.com',
  duration: 45,
});

logger.error('Database connection failed', {
  error: err.message,
  stack: err.stack,
  database: 'users_db',
  retryAttempt: 3,
});
```

### Log Levels
| Level | Use Case | Example |
|-------|----------|---------|
| ERROR | Action failed, needs attention | Database connection lost |
| WARN | Something unexpected but handled | Rate limit approaching |
| INFO | Normal significant events | User created, deployment started |
| DEBUG | Detailed diagnostic info | Query executed, cache hit |
| TRACE | Very detailed, every step | Function entry/exit |

### Correlation IDs
```typescript
// Generate at request entry point
const correlationId = crypto.randomUUID();

// Include in all logs
const childLogger = logger.child({ correlationId, requestId });

// Pass to downstream services
fetch('http://payment-service/charge', {
  headers: { 'X-Correlation-ID': correlationId },
});

// Query all logs for a request
// { correlationId: "abc-123" }
```

### Log Aggregation
```
Application → Fluent Bit / Fluentd → Elasticsearch / Loki → Kibana / Grafana
                     ↓
              Filter, parse, enrich
                     ↓
              Route to destinations
```

## Metrics

### Metric Types
```
Counter:     Only increases (requests, errors, bytes sent)
             http_requests_total{method="GET", status="200"} 15432

Gauge:       Goes up and down (memory, CPU, queue size)
             memory_usage_bytes 524288000

Histogram:   Distribution of values (latency, response size)
             http_request_duration_seconds_bucket{le="0.1"} 8000
             http_request_duration_seconds_bucket{le="0.5"} 14000
             http_request_duration_seconds_sum 3500.5
             http_request_duration_seconds_count 15432

Summary:     Pre-calculated quantiles (similar to histogram)
             http_request_duration_seconds{quantile="0.5"} 0.05
             http_request_duration_seconds{quantile="0.99"} 0.25
```

### RED Method (Services)
```
Rate:      Number of requests per second
           rate(http_requests_total[5m])

Errors:    Number of failed requests per second
           rate(http_requests_total{status=~"5.."}[5m])

Duration:  Time each request takes
           histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

### USE Method (Infrastructure)
```
Utilization: Average time resource is busy
             node_cpu_seconds_total{mode="idle"}

Saturation:  Work queued/waiting
             node_load1 / node_cpu_count

Errors:      Error events
             node_disk_io_time_weighted
```

### Custom Metrics
```typescript
import { Registry, Counter, Histogram } from 'prom-client';

const register = new Registry();

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [register],
});

const activeUsers = new Gauge({
  name: 'active_users_total',
  help: 'Number of currently active users',
  registers: [register],
});

// Middleware to record metrics
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});
```

## Distributed Tracing

### OpenTelemetry
```typescript
import { trace, context, SpanStatusCode } from '@opentelemetry/api';
import { NodeSDK } from '@opentelemetry/sdk-node';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://jaeger:4318/v1/traces',
  }),
});

const tracer = trace.getTracer('order-service');

async function createOrder(order: Order) {
  return tracer.startActiveSpan('createOrder', async (span) => {
    span.setAttribute('order.id', order.id);
    span.setAttribute('order.total', order.total);
    span.setAttribute('user.id', order.userId);
    
    try {
      // Database call creates child span automatically
      const result = await db.order.create(order);
      
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (error) {
      span.setStatus({ code: SpanStatusCode.ERROR });
      span.recordException(error as Error);
      throw error;
    } finally {
      span.end();
    }
  });
}
```

### Trace Context Propagation
```
Service A ──[trace_id=abc, span_id=1]──> Service B ──[trace_id=abc, span_id=2]──> Service C
     │                                         │                                         │
  span: 1                                  span: 2                                  span: 3
  parent: -                                parent: 1                                parent: 2
```

## SLO/SLI/SLA

### Definitions
```
SLI (Service Level Indicator): What you measure
  - Availability: % of successful requests
  - Latency: Time to serve requests
  - Throughput: Requests per second
  - Error rate: % of failed requests

SLO (Service Level Objective): Your target
  - 99.9% availability over 30 days
  - 95% of requests under 200ms
  - Error rate below 0.1%

SLA (Service Level Agreement): Contract with users
  - 99.9% availability → $X credit if breached
  - Consequence of missing SLO
```

### Error Budget
```
SLO: 99.9% availability over 30 days
Total minutes in 30 days: 43,200
Allowed downtime: 43.2 minutes (error budget)

If you've used 30 minutes of error budget:
  - 13.2 minutes remaining
  - Consider slowing deployments
  - Focus on reliability over features

If error budget is exhausted:
  - Freeze feature deployments
  - All effort goes to reliability
  - Postmortem required
```

### Multi-Window Burn Rate Alerting
```yaml
# Prometheus alerting rules
groups:
  - name: slo-burn-rate
    rules:
      # Page: 14.4x burn rate over 5m (budget exhausted in ~2 hours)
      - alert: HighErrorRate
        expr: |
          (
            job:http_errors:rate5m{job="api"} / job:http_requests:rate5m{job="api"}
          ) > (14.4 * 0.001)
          and
          (
            job:http_errors:rate1h{job="api"} / job:http_requests:rate1h{job="api"}
          ) > (14.4 * 0.001)
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Error budget burning at 14.4x rate"

      # Ticket: 6x burn rate over 30m (budget exhausted in ~5 hours)
      - alert: ElevatedErrorRate
        expr: |
          (
            job:http_errors:rate30m{job="api"} / job:http_requests:rate30m{job="api"}
          ) > (6 * 0.001)
          and
          (
            job:http_errors:rate6h{job="api"} / job:http_requests:rate6h{job="api"}
          ) > (6 * 0.001)
        for: 5m
        labels:
          severity: warning
```

### Burn Rate Windows
| Burn Rate | Short Window | Long Window | Time to Exhaust | Severity |
|-----------|-------------|-------------|-----------------|----------|
| 14.4x     | 5m          | 1h          | ~2 hours        | Page     |
| 6x        | 30m         | 6h          | ~5 hours        | Page     |
| 3x        | 1h          | 1d          | ~10 hours       | Ticket   |
| 1x        | 3h          | 1d          | ~1 day          | Ticket   |

## Alerting

### Alert Best Practices
- Every alert must require human action
- Every alert must have a runbook
- Page only for symptoms users experience
- Use multi-window burn rate to reduce false positives
- Group related alerts
- Include context in alert messages

### Alert Fatigue Prevention
```
Symptoms over causes:
  ✅ Page: "High error rate on checkout API"
  ❌ Page: "CPU at 90% on server-3"

Actionable alerts:
  ✅ Page: "Database connection pool exhausted — check connections"
  ❌ Page: "Memory usage at 85%"

Severity levels:
  Critical: Page immediately — users are affected
  Warning: Ticket — investigate during business hours
  Info: Log only — for awareness
```

## Dashboards

### Golden Signals Dashboard
```
1. Latency
   - p50, p95, p99 response times
   - Time series over 1h, 24h, 7d

2. Traffic
   - Requests per second
   - By endpoint, method, status code

3. Errors
   - Error rate over time
   - Error breakdown by type
   - Error budget remaining

4. Saturation
   - CPU, memory, disk usage
   - Connection pool utilization
   - Queue depth
```

### Grafana Dashboard JSON
```json
{
  "panels": [
    {
      "title": "Request Rate",
      "targets": [{
        "expr": "rate(http_requests_total[5m])",
        "legendFormat": "{{method}} {{status_code}}"
      }]
    },
    {
      "title": "Error Budget Remaining",
      "targets": [{
        "expr": "1 - (sum(rate(http_requests_total{status=~\"5..\"}[30d])) / sum(rate(http_requests_total[30d])))",
        "thresholds": [0.999, 0.99]
      }]
    }
  ]
}
```

## Tool Stack

### Prometheus Stack
```
Prometheus:    Metrics collection and storage
Grafana:       Dashboards and visualization
Alertmanager:  Alert routing, deduplication, silencing
Node Exporter: Host metrics
cAdvisor:      Container metrics
Blackbox:      External probing (HTTP, TCP, DNS)

# Prometheus config
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'api'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['api:3000']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

### Logging Stack
```
Loki:        Log aggregation (like Prometheus for logs)
Promtail:    Log collection agent
Grafana:     Log exploration and dashboards

# Query logs in Grafana
{service="api", level="error"} | json | duration > 1000
```

### Tracing Stack
```
Jaeger:      Trace storage and UI
Tempo:       Grafana-native trace storage
OpenTelemetry: Instrumentation library
Collector:   OTel data pipeline
```

## Incident Response

### Runbook Template
```markdown
# Incident Runbook: High Error Rate

## Symptoms
- Error rate > 1% on API endpoints
- Alert: HighErrorRate firing

## Immediate Actions
1. Check Grafana dashboard: [link]
2. Check recent deployments: [link]
3. Check error logs: [link]

## Common Causes
1. Bad deployment → Rollback
2. Database connection issues → Check connection pool
3. External service down → Check dependencies

## Rollback Procedure
kubectl rollout undo deployment/api -n production

## Escalation
- If not resolved in 15 min → Page on-call engineer
- If not resolved in 30 min → Page team lead
- If not resolved in 1 hour → Page engineering manager
```

### Postmortem Template
```markdown
# Postmortem: [Incident Title]

## Summary
What happened, impact, duration

## Timeline
- 14:00 — Deployment started
- 14:05 — Error rate increased
- 14:07 — Alert fired
- 14:10 — Engineer acknowledged
- 14:15 — Root cause identified
- 14:20 — Rollback completed
- 14:25 — Service recovered

## Root Cause
Technical explanation of what went wrong

## Impact
- Duration: 20 minutes
- Affected users: ~500
- Failed requests: ~2000

## Action Items
- [ ] Add circuit breaker for external service (Owner, Due date)
- [ ] Improve alerting threshold (Owner, Due date)
- [ ] Add integration test for this scenario (Owner, Due date)

## Lessons Learned
What went well, what didn't, where we got lucky
```

## When to Use Me

Use this skill when:
- Setting up monitoring and observability
- Defining SLOs and error budgets
- Configuring alerts and dashboards
- Implementing distributed tracing
- Setting up log aggregation
- Creating incident response procedures
- Writing runbooks and postmortems

## Quality Checklist

- [ ] Structured logging with correlation IDs
- [ ] RED metrics collected for all services
- [ ] SLOs defined for critical user journeys
- [ ] Error budget tracking implemented
- [ ] Multi-window burn rate alerts configured
- [ ] Every pageable alert has a runbook
- [ ] Dashboards show golden signals
- [ ] Distributed tracing across services
- [ ] Log retention policy defined
- [ ] Postmortem process documented
