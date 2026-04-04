---
name: api-design-master
description: Design robust, scalable REST and GraphQL APIs following industry best practices. Covers resource modeling, HTTP conventions, pagination, versioning, error handling, and OpenAPI documentation.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: backend
---

# API Design Master

## What I Do

I help design clean, consistent, and developer-friendly APIs following proven patterns and industry standards. I ensure APIs are intuitive, well-documented, and built to scale.

## RESTful Design Principles

### Resource Modeling
- Use nouns for resources, never verbs: `/users`, not `/getUsers`
- Use plural nouns consistently: `/articles`, not `/article`
- Nest resources to show relationships: `/users/123/orders`
- Keep nesting depth to 2-3 levels max
- Flatten deep hierarchies with query params: `/orders?userId=123`

### HTTP Methods
| Method    | Purpose                    | Idempotent | Safe |
|-----------|----------------------------|------------|------|
| GET       | Retrieve resource(s)       | Yes        | Yes  |
| POST      | Create new resource        | No         | No   |
| PUT       | Full update/replace        | Yes        | No   |
| PATCH     | Partial update             | No*        | No   |
| DELETE    | Remove resource            | Yes        | No   |
| HEAD      | Get headers only           | Yes        | Yes  |
| OPTIONS   | Get allowed methods        | Yes        | Yes  |

*PATCH is idempotent only if the operation itself is (e.g., setting a value vs appending)

### URL Conventions
- Use kebab-case: `/blog-posts`, not `/blogPosts` or `/blog_posts`
- Use lowercase only
- Avoid file extensions in URLs
- Use query parameters for filtering, sorting, pagination
- Version in URL or header, not both

## HTTP Status Codes

### Success (2xx)
- `200 OK` — Successful GET, PUT, PATCH
- `201 Created` — Successful POST (return Location header)
- `204 No Content` — Successful DELETE
- `202 Accepted` — Async operation accepted for processing

### Client Errors (4xx)
- `400 Bad Request` — Malformed request body or params
- `401 Unauthorized` — Missing or invalid authentication
- `403 Forbidden` — Authenticated but no permission
- `404 Not Found` — Resource doesn't exist
- `405 Method Not Allowed` — Wrong HTTP method for endpoint
- `409 Conflict` — Resource conflict (duplicate, stale data)
- `415 Unsupported Media Type` — Wrong Content-Type
- `422 Unprocessable Entity` — Valid syntax but semantic errors (validation)
- `429 Too Many Requests` — Rate limit exceeded

### Server Errors (5xx)
- `500 Internal Server Error` — Unexpected server failure
- `502 Bad Gateway` — Invalid upstream response
- `503 Service Unavailable` — Temporarily down (maintenance, overload)
- `504 Gateway Timeout` — Upstream didn't respond in time

## Response Format

### Success Response
```json
{
  "data": {
    "id": "usr_abc123",
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    },
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### Collection Response
```json
{
  "data": [...],
  "meta": {
    "total": 150,
    "page": 2,
    "perPage": 20,
    "totalPages": 8
  },
  "links": {
    "self": "/users?page=2&perPage=20",
    "first": "/users?page=1&perPage=20",
    "prev": "/users?page=1&perPage=20",
    "next": "/users?page=3&perPage=20",
    "last": "/users?page=8&perPage=20"
  }
}
```

### Error Response (RFC 7807)
```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "One or more fields failed validation",
  "instance": "/users",
  "errors": [
    {
      "field": "email",
      "message": "Email already exists",
      "code": "DUPLICATE_VALUE"
    },
    {
      "field": "password",
      "message": "Must be at least 8 characters",
      "code": "MIN_LENGTH"
    }
  ]
}
```

## Pagination Strategies

### Offset-Based (Simple)
```
GET /users?page=2&perPage=20
```
- Pros: Simple, supports random page access
- Cons: Performance degrades with large offsets, inconsistent with concurrent writes
- Best for: Small datasets, admin panels

### Cursor-Based (Recommended)
```
GET /users?limit=20&cursor=eyJpZCI6MTAwfQ
```
- Pros: Consistent results, performs well at any scale
- Cons: No random page access, can't jump to "page 5"
- Best for: APIs, infinite scroll, large datasets

### Keyset (Seek) Pagination
```
GET /users?limit=20&after_id=100&sort=created_at
```
- Pros: Very fast with proper index, consistent
- Cons: Only forward/backward navigation
- Best for: Real-time feeds, activity streams

## Filtering, Sorting, Searching

### Filtering
```
GET /users?status=active&role=admin&createdAfter=2024-01-01
GET /products?price[gte]=10&price[lte]=100&category=electronics
```

### Sorting
```
GET /users?sort=-createdAt,name
# Minus prefix = descending, no prefix = ascending
```

### Searching
```
GET /users?search=john
# For advanced search, use dedicated endpoint:
POST /users/search
{
  "query": "john",
  "filters": { "status": "active" },
  "fields": ["name", "email"]
}
```

### Field Selection (Sparse Fieldsets)
```
GET /users?fields=id,name,email
GET /articles?include=author,comments&fields[author]=name,avatar
```

## API Versioning

### URL Path (Most Common)
```
GET /v1/users
GET /v2/users
```
- Pros: Explicit, easy to route, cacheable
- Cons: URL changes between versions

### Header-Based
```
GET /users
Accept: application/vnd.myapi.v2+json
```
- Pros: Clean URLs, proper content negotiation
- Cons: Harder to test in browser, less discoverable

### Versioning Rules
- Never break existing version — add new fields, don't remove
- Deprecate with `Sunset` header and `Deprecation` header
- Maintain at least 2 versions simultaneously
- Document breaking changes clearly
- Set deprecation timeline (minimum 6 months notice)

```
Deprecation: true
Sunset: Sat, 01 Jan 2025 00:00:00 GMT
Link: </v2/users>; rel="successor-version"
```

## Rate Limiting

### Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1704067200
Retry-After: 60
```

### Strategies
- Token bucket: Smooth rate with burst allowance
- Fixed window: Simple, but allows burst at boundaries
- Sliding window: More accurate, prevents boundary bursts
- Per-endpoint limits: Stricter on expensive operations

### Standard Limits
- Public/unauthenticated: 60-100 req/min
- Authenticated: 1000-5000 req/min
- Write operations: 30-100 req/min
- Search/heavy operations: 10-30 req/min

## Authentication & Authorization

### API Keys
- For server-to-server communication
- Pass in header: `X-API-Key: your_key`
- Rotate regularly, never expose in client code

### Bearer Tokens (JWT/OAuth2)
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```
- Short-lived access tokens (15min-1hr)
- Refresh tokens for renewal
- Include minimal claims in JWT

### OAuth2 Flows
- Authorization Code + PKCE: Public clients (SPA, mobile)
- Client Credentials: Machine-to-machine
- Device Code: CLI, IoT devices
- NEVER use Implicit flow (deprecated)

## Idempotency

### Idempotency Keys
```
POST /payments
Idempotency-Key: req_abc123
{ "amount": 100, "currency": "USD" }
```
- Store key + response for 24-48 hours
- Return cached response for duplicate keys
- Required for payment and critical operations

## CORS Configuration

```
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```
- Never use `*` with credentials
- List specific origins in production
- Preflight cache for 24 hours

## GraphQL vs REST

### Use REST When
- Simple CRUD operations
- Caching is critical (HTTP caching works out of the box)
- Multiple independent clients with different needs
- Team is more familiar with REST

### Use GraphQL When
- Clients need flexible data fetching
- Multiple related resources in one request
- Rapidly evolving frontend requirements
- Mobile apps need to minimize payload

### Best of Both
- REST for simple, cacheable resources
- GraphQL for complex, nested data queries
- Consider tRPC for full-stack TypeScript apps

## OpenAPI Documentation

### Structure
```yaml
openapi: 3.1.0
info:
  title: My API
  version: 2.0.0
  description: API description
  contact:
    name: API Support
    email: api@example.com
servers:
  - url: https://api.example.com/v2
paths:
  /users:
    get:
      summary: List users
      tags: [Users]
      parameters:
        - name: page
          in: query
          schema: { type: integer, default: 1 }
        - name: perPage
          in: query
          schema: { type: integer, default: 20, maximum: 100 }
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserCollection'
        '401':
          $ref: '#/components/responses/Unauthorized'
components:
  schemas:
    User:
      type: object
      required: [id, name, email]
      properties:
        id: { type: string, format: uuid }
        name: { type: string, minLength: 1, maxLength: 100 }
        email: { type: string, format: email }
        status: { type: string, enum: [active, inactive, banned] }
        createdAt: { type: string, format: date-time }
```

## Webhooks

### Design
```json
{
  "id": "evt_abc123",
  "type": "user.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "id": "usr_abc123",
    "name": "John Doe"
  }
}
```

### Delivery
- POST to registered endpoint
- Include signature header: `X-Webhook-Signature: sha256=...`
- Retry with exponential backoff (1min, 5min, 30min, 2hr, 12hr)
- Mark as failed after max retries (typically 5-7 attempts)
- Provide webhook dashboard for monitoring and replay

## GraphQL Design

### Schema Design
```graphql
type Query {
  user(id: ID!): User
  users(status: UserStatus, page: Int = 1, perPage: Int = 20): UserConnection!
  product(slug: String!): Product
}

type Mutation {
  createUser(input: CreateUserInput!): UserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UserPayload!
  deleteUser(id: ID!): DeletePayload!
}

type User {
  id: ID!
  name: String!
  email: String!
  status: UserStatus!
  posts(first: Int = 10, after: String): PostConnection!
  createdAt: DateTime!
}

type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}

enum UserStatus {
  ACTIVE
  INACTIVE
  BANNED
}

input CreateUserInput {
  name: String!
  email: String!
  role: UserRole = USER
}

union UserPayload = User | ValidationError
```

### DataLoader (N+1 Prevention)
```typescript
import DataLoader from 'dataloader';

// Batch function — called with array of keys
const batchUsers = async (ids: readonly string[]): Promise<User[]> => {
  const users = await db.user.findMany({
    where: { id: { in: ids as string[] } },
  });
  // Return in same order as input keys
  return ids.map(id => users.find(u => u.id === id)!);
};

// Create loader per request
const userLoader = new DataLoader(batchUsers);

// In resolver
const resolvers = {
  Post: {
    author: (post) => userLoader.load(post.authorId),
  },
};
```

## gRPC

### Protocol Buffers
```protobuf
syntax = "proto3";
package orderservice.v1;

option go_package = "github.com/example/orderservice/proto";

service OrderService {
  rpc GetOrder(GetOrderRequest) returns (Order);
  rpc CreateOrder(CreateOrderRequest) returns (Order);
  rpc StreamOrders(StreamOrdersRequest) returns (stream Order);
  rpc ProcessOrders(stream Order) returns (ProcessResult);
}

message Order {
  string id = 1;
  string user_id = 2;
  repeated OrderItem items = 3;
  OrderStatus status = 4;
  google.protobuf.Timestamp created_at = 5;
}

message OrderItem {
  string product_id = 1;
  int32 quantity = 2;
  Money price = 3;
}

message Money {
  string currency = 1;
  int64 units = 2;
  int32 nanos = 3;
}

enum OrderStatus {
  ORDER_STATUS_UNSPECIFIED = 0;
  ORDER_STATUS_PENDING = 1;
  ORDER_STATUS_PAID = 2;
  ORDER_STATUS_SHIPPED = 3;
}
```

### gRPC Best Practices
- Use proto3 with explicit package versioning
- Prefix enum values with type name (avoid collisions)
- Use `google.protobuf.Timestamp` for dates
- Use `oneof` for mutually exclusive fields
- Implement server interceptors for auth, logging, error handling
- Use deadlines/timeouts on all client calls
- Prefer unary RPCs for simple requests, streaming for large data

## WebSocket API

### Design Patterns
```typescript
// Connection management
interface WSConnection {
  id: string;
  userId: string;
  ws: WebSocket;
  subscriptions: Set<string>;
  lastPing: Date;
}

// Message format
interface WSMessage {
  type: 'subscribe' | 'unsubscribe' | 'event' | 'ping' | 'pong';
  channel: string;
  payload?: Record<string, any>;
  id?: string; // For request-response correlation
}

// Server handler
wss.on('connection', (ws, req) => {
  const connection = registerConnection(ws, req);
  
  ws.on('message', (data) => {
    const msg = JSON.parse(data.toString()) as WSMessage;
    handleMessage(connection, msg);
  });
  
  ws.on('close', () => unregisterConnection(connection));
  
  // Heartbeat
  const interval = setInterval(() => {
    if (Date.now() - connection.lastPing.getTime() > 30000) {
      ws.terminate();
      return;
    }
    ws.send(JSON.stringify({ type: 'ping' }));
  }, 15000);
  
  ws.on('pong', () => { connection.lastPing = new Date(); });
});

// Client reconnection
class WSClient {
  private reconnectDelay = 1000;
  private maxDelay = 30000;
  
  private connect() {
    this.ws = new WebSocket(this.url);
    this.ws.onclose = () => {
      setTimeout(() => {
        this.reconnectDelay = Math.min(this.reconnectDelay * 2, this.maxDelay);
        this.connect();
      }, this.reconnectDelay);
    };
    this.ws.onopen = () => { this.reconnectDelay = 1000; };
  }
}
```

## When to Use Me

Use this skill when:
- Designing new API endpoints
- Refactoring existing API structure
- Writing API documentation
- Implementing authentication/authorization
- Setting up rate limiting
- Creating webhook systems
- Choosing between REST and GraphQL
- Versioning an existing API
- Designing GraphQL schemas
- Implementing gRPC services
- Building WebSocket APIs

## Quality Checklist

- [ ] URLs use plural nouns and kebab-case
- [ ] Correct HTTP methods and status codes
- [ ] Consistent error response format
- [ ] Pagination implemented for collections
- [ ] Rate limiting headers included
- [ ] API versioning strategy defined
- [ ] OpenAPI/Swagger documentation complete
- [ ] GraphQL schema follows naming conventions
- [ ] DataLoader used to prevent N+1 queries
- [ ] gRPC uses proper proto3 conventions
- [ ] WebSocket has heartbeat/reconnection logic
- [ ] Webhook signatures verified
- [ ] Idempotency keys for critical operations
- [ ] CORS properly configured
- [ ] Authentication/authorization in place
- [ ] Idempotency keys for critical operations
- [ ] Webhook signatures verified
- [ ] Response times under 200ms for simple endpoints
