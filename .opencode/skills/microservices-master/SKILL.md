---
name: microservices-master
description: Design and implement microservice architectures following proven patterns. Covers service decomposition, communication, saga pattern, API gateway, event-driven design, and distributed tracing.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: architecture
---

# Microservices Master

## What I Do

I help design and implement microservice architectures that are scalable, resilient, and maintainable. I apply proven patterns for service communication, data management, and deployment.

## Service Decomposition

### Bounded Contexts (DDD)
```
Monolith boundaries:
┌─────────────────────────────────────┐
│           Monolith                  │
│  ┌──────────┐  ┌──────────┐        │
│  │  Orders  │  │ Payments │        │
│  ├──────────┤  ├──────────┤        │
│  │ Inventory│  │ Shipping │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │  Users   │  │  Catalog │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘

Decomposed:
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Orders  │ │Payments │ │Inventory│
│ Service │ │ Service │ │ Service │
└────┬────┘ └────┬────┘ └────┬────┘
     │           │           │
┌────┴────┐ ┌────┴────┐ ┌────┴────┐
│  Users  │ │ Catalog │ │Shipping │
│ Service │ │ Service │ │ Service │
└─────────┘ └─────────┘ └─────────┘
```

### Decomposition Strategies
- **By business capability**: Order management, payment processing
- **By subdomain**: Core domain, supporting subdomains, generic subdomains
- **By verb/use case**: Ordering, shipping, billing
- **Strangler Fig**: Gradually extract services from monolith

### Service Size Guidelines
- Team size: 2-pizza team (5-9 people) per service
- Codebase: Small enough to understand in a day
- Deploy independently without coordinating with other teams
- Own their own data — no shared databases

## Communication Patterns

### Synchronous (REST/gRPC)
```typescript
// REST — simple, human-readable, cacheable
GET /api/orders/123
POST /api/orders
PUT /api/orders/123/status

// gRPC — high performance, typed contracts
service OrderService {
  rpc GetOrder(OrderRequest) returns (OrderResponse);
  rpc CreateOrder(CreateOrderRequest) returns (OrderResponse);
  rpc StreamOrders(StreamRequest) returns (stream Order);
}
```

### Asynchronous (Message Broker)
```typescript
// Event-driven communication
// Order Service publishes
await broker.publish('orders', {
  type: 'order.created',
  data: { orderId: '123', userId: '456', total: 99.99 },
  timestamp: new Date().toISOString(),
  correlationId: 'corr-abc',
});

// Payment Service subscribes
await broker.subscribe('orders', 'order.created', async (event) => {
  await paymentService.charge(event.data);
  await broker.publish('payments', {
    type: 'payment.completed',
    data: { orderId: event.data.orderId, transactionId: 'txn-789' },
    correlationId: event.correlationId,
  });
});
```

### Communication Decision Tree
```
Need immediate response?
├── Yes → Synchronous (REST/gRPC)
│   ├── Simple, public API? → REST
│   └── High performance, internal? → gRPC
└── No → Asynchronous (Message Broker)
    ├── Need ordering guarantee? → Kafka
    ├── Simple pub/sub? → RabbitMQ / Redis
    └── Cloud-native? → SQS/SNS, Pub/Sub
```

## Saga Pattern

### Choreography (Event-Based)
```
Order Service          Payment Service         Inventory Service
     │                       │                        │
     ├── Create Order ───────│────────────────────────│
     │                       │                        │
     ├── OrderCreated ──────>│                        │
     │                       ├── Reserve Funds ───────│
     │                       │                        │
     │                       ├── PaymentCompleted ───>│
     │                       │                        ├── Reserve Stock
     │                       │                        │
     │                       │                        ├── StockReserved ──>
     │                       │                        │
     │<── OrderConfirmed ────│<───────────────────────│
```

```typescript
// Each service handles its part and emits events
class OrderSaga {
  async createOrder(order: Order) {
    // 1. Create order in PENDING state
    const order = await this.orderRepo.create({ ...order, status: 'PENDING' });
    
    // 2. Emit event — other services react
    await this.eventBus.publish('order.created', {
      orderId: order.id,
      amount: order.total,
      items: order.items,
    });
    
    return order;
  }
  
  // Listen for completion/failure
  async onPaymentCompleted(event: PaymentCompletedEvent) {
    await this.orderRepo.update(event.orderId, { status: 'PAID' });
    await this.eventBus.publish('order.paid', { orderId: event.orderId });
  }
  
  async onPaymentFailed(event: PaymentFailedEvent) {
    await this.orderRepo.update(event.orderId, { status: 'CANCELLED' });
    // Compensating action — release reserved inventory
    await this.eventBus.publish('order.cancelled', { orderId: event.orderId });
  }
}
```

### Orchestration (Central Coordinator)
```typescript
class OrderOrchestrator {
  async executeOrder(order: Order) {
    const saga = new Saga(order.id);
    
    try {
      // Step 1: Reserve inventory
      await this.inventoryService.reserve(order.items);
      saga.addStep('inventory_reserved');
      
      // Step 2: Process payment
      await this.paymentService.charge(order.total, order.paymentMethod);
      saga.addStep('payment_completed');
      
      // Step 3: Create shipment
      await this.shippingService.createShipment(order);
      saga.addStep('shipment_created');
      
      // All steps succeeded
      await this.orderRepo.update(order.id, { status: 'CONFIRMED' });
    } catch (error) {
      // Compensating transactions — undo in reverse order
      await saga.compensate();
      await this.orderRepo.update(order.id, { status: 'FAILED' });
      throw error;
    }
  }
}

class Saga {
  private steps: string[] = [];
  
  async compensate() {
    const compensations = [...this.steps].reverse();
    for (const step of compensations) {
      await this.executeCompensation(step);
    }
  }
  
  private async executeCompensation(step: string) {
    switch (step) {
      case 'shipment_created':
        await shippingService.cancelShipment();
        break;
      case 'payment_completed':
        await paymentService.refund();
        break;
      case 'inventory_reserved':
        await inventoryService.release();
        break;
    }
  }
}
```

### When to Use Which
| Pattern | Pros | Cons | Use When |
|---------|------|------|----------|
| Choreography | Loose coupling, easy to add services | Hard to track, cyclic dependencies | Few services, simple flows |
| Orchestration | Clear flow, easy monitoring, no cyclic deps | Central point, tighter coupling | Complex flows, many services |

## API Gateway

### Responsibilities
- Request routing and aggregation
- Authentication and authorization
- Rate limiting and throttling
- Request/response transformation
- Caching
- Load balancing
- Circuit breaking

### Implementation
```typescript
import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';

const app = express();

// Authentication middleware
app.use('/api/*', authenticateToken);

// Rate limiting
app.use('/api/*', rateLimit({ windowMs: 60000, max: 100 }));

// Route to services
app.use('/api/orders', createProxyMiddleware({
  target: process.env.ORDER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: { '^/api/orders': '' },
}));

app.use('/api/users', createProxyMiddleware({
  target: process.env.USER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: { '^/api/users': '' },
}));

// Request aggregation
app.get('/api/dashboard/:userId', async (req, res) => {
  const [orders, notifications, stats] = await Promise.all([
    fetch(`${ORDER_SERVICE}/users/${req.params.userId}/orders`),
    fetch(`${NOTIFICATION_SERVICE}/users/${req.params.userId}/notifications`),
    fetch(`${ANALYTICS_SERVICE}/users/${req.params.userId}/stats`),
  ]);
  
  res.json({
    orders: await orders.json(),
    notifications: await notifications.json(),
    stats: await stats.json(),
  });
});
```

## Event-Driven Architecture

### Event Sourcing
```typescript
// Store events, not state
interface Event {
  id: string;
  aggregateId: string;
  type: string;
  data: Record<string, any>;
  version: number;
  timestamp: Date;
}

class EventStore {
  async append(aggregateId: string, events: Event[]): Promise<void> {
    // Append events atomically
    await db.transaction(async (tx) => {
      for (const event of events) {
        await tx.execute(
          'INSERT INTO events (aggregate_id, type, data, version) VALUES (?, ?, ?, ?)',
          [aggregateId, event.type, JSON.stringify(event.data), event.version]
        );
      }
    });
  }
  
  async getEvents(aggregateId: string): Promise<Event[]> {
    return db.query('SELECT * FROM events WHERE aggregate_id = ? ORDER BY version', [aggregateId]);
  }
}

// Rebuild state from events
class OrderAggregate {
  static fromEvents(events: Event[]): OrderAggregate {
    const order = new OrderAggregate();
    for (const event of events) {
      order.applyEvent(event);
    }
    return order;
  }
  
  private applyEvent(event: Event) {
    switch (event.type) {
      case 'OrderCreated':
        this.status = 'PENDING';
        this.items = event.data.items;
        break;
      case 'PaymentReceived':
        this.status = 'PAID';
        break;
      case 'OrderShipped':
        this.status = 'SHIPPED';
        break;
    }
  }
}
```

### CQRS (Command Query Responsibility Segregation)
```
Commands (Write)                    Queries (Read)
     │                                    │
     ▼                                    ▼
┌──────────┐                        ┌──────────┐
│  Command │                        │   Read   │
│  Handler │                        │  Model   │
└────┬─────┘                        └────▲─────┘
     │                                  │
     ▼                                  │
┌──────────┐      Events/Updates       │
│  Write   │ ────────────────────────> │
│  Model   │                          │
└──────────┘                          │
                                      │
                              ┌───────┴───────┐
                              │  Materialized │
                              │    Views      │
                              └───────────────┘
```

## Service Mesh

### Sidecar Pattern
```
┌───────────────────────────┐
│       Application         │
│  ┌─────────────────────┐  │
│  │   Business Logic    │  │
│  └──────────┬──────────┘  │
│             │ localhost   │
│  ┌──────────▼──────────┐  │
│  │    Sidecar Proxy    │  │
│  │  (Envoy/Linkerd)    │  │
│  └──────────┬──────────┘  │
└─────────────┼─────────────┘
              │
              ▼
        Other Services
```

### Service Mesh Capabilities
- mTLS between services (automatic encryption)
- Traffic management (canary, blue-green, A/B testing)
- Observability (metrics, traces, logs)
- Resilience (retries, timeouts, circuit breakers)
- Policy enforcement (rate limiting, access control)

## Data Management

### Database per Service
```
Order Service ────► orders_db
Payment Service ──► payments_db
User Service ─────► users_db
Inventory Service ─► inventory_db

Rules:
- Each service owns its database
- No direct database access between services
- Communicate through APIs or events
- Accept eventual consistency
```

### CDC (Change Data Capture)
```typescript
// Debezium captures database changes and publishes to Kafka
// Order Service writes to its DB
// Debezium reads the binlog/WAL
// Events published to Kafka
// Other services consume and update their read models

// Example: Update search index when product changes
// Product DB → Debezium → Kafka → Search Indexer → Elasticsearch
```

## Distributed Tracing

### Correlation IDs
```typescript
// Generate at entry point
const correlationId = crypto.randomUUID();

// Pass through all service calls
async function callService(url: string, data: any, correlationId: string) {
  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Correlation-ID': correlationId,
      'X-Request-ID': crypto.randomUUID(),
    },
    body: JSON.stringify(data),
  });
}

// Include in all logs
logger.info('Processing order', { correlationId, orderId: '123' });
```

### OpenTelemetry
```typescript
import { trace, context } from '@opentelemetry/api';

const tracer = trace.getTracer('order-service');

async function createOrder(order: Order) {
  return tracer.startActiveSpan('createOrder', async (span) => {
    span.setAttribute('order.id', order.id);
    span.setAttribute('order.total', order.total);
    
    try {
      const result = await processOrder(order);
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

## Testing Strategies

### Contract Testing (Pact)
```typescript
// Consumer test — defines expected contract
const pact = new Pact({ consumer: 'OrderService', provider: 'PaymentService' });

pact.addInteraction({
  state: 'payment service is available',
  uponReceiving: 'a request to charge a payment',
  withRequest: {
    method: 'POST',
    path: '/payments',
    body: { amount: 99.99, currency: 'USD' },
  },
  willRespondWith: {
    status: 200,
    body: { transactionId: somethingLike('txn-123'), status: 'completed' },
  },
});
```

## When to Use Me

Use this skill when:
- Decomposing a monolith into microservices
- Designing service communication patterns
- Implementing saga pattern for distributed transactions
- Setting up API gateway
- Building event-driven architectures
- Implementing distributed tracing
- Designing data management strategies

## Quality Checklist

- [ ] Services have clear bounded contexts
- [ ] Each service owns its database
- [ ] Communication pattern chosen per use case
- [ ] Saga pattern handles distributed transactions
- [ ] Compensating actions for all failure scenarios
- [ ] Correlation IDs propagated across services
- [ ] Circuit breakers for external calls
- [ ] API gateway handles auth, rate limiting, routing
- [ ] Contract tests between services
- [ ] Services deploy independently
- [ ] Distributed tracing implemented
- [ ] Health checks and readiness probes configured
