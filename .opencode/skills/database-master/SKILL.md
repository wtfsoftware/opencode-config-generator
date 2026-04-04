---
name: database-master
description: Design efficient database schemas, write optimized queries, and manage migrations. Covers SQL and NoSQL, indexing strategies, transaction management, and performance tuning.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: backend
---

# Database Master

## What I Do

I help design efficient database schemas, write optimized queries, and implement robust data management strategies. I ensure databases are performant, scalable, and maintainable.

## Schema Design

### Normalization

**1NF (First Normal Form)**
- Atomic values — no repeating groups or arrays in a single column
- Each cell contains a single value
- Each record is unique (primary key)

**2NF (Second Normal Form)**
- Must be in 1NF
- No partial dependencies — all non-key attributes depend on the entire primary key

**3NF (Third Normal Form)**
- Must be in 2NF
- No transitive dependencies — non-key attributes depend only on the primary key

**When to Denormalize**
- Read-heavy workloads with complex joins
- Reporting/analytics tables
- Caching layers
- Microservices with bounded contexts
- Always document why and what the trade-off is

### Naming Conventions
- Tables: plural, snake_case (`users`, `order_items`)
- Columns: singular, snake_case (`first_name`, `created_at`)
- Primary keys: `id` (or `table_name_id` in joins)
- Foreign keys: `singular_table_name_id` (`user_id`, `order_id`)
- Indexes: `idx_table_column(s)` (`idx_users_email`, `idx_orders_user_id_status`)
- Unique constraints: `uq_table_column(s)`
- Junction tables: alphabetical order (`order_products`, not `products_orders`)

### Data Types

**Always Use**
- `UUID` or auto-increment `BIGINT` for primary keys
- `TIMESTAMPTZ` (timestamp with time zone) for dates
- `DECIMAL/NUMERIC` for money, never `FLOAT`
- `VARCHAR(n)` with reasonable limits for strings
- `BOOLEAN` for true/false values
- `JSONB` (PostgreSQL) for flexible semi-structured data

**Avoid**
- `TEXT` without length limit (use VARCHAR)
- `FLOAT/REAL` for precise values
- Storing files in database (use object storage, store URL)
- `NULL` for boolean — use `NOT NULL DEFAULT false`

### Common Patterns

**Soft Deletes**
```sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;
-- Query: WHERE deleted_at IS NULL
-- Always index: CREATE INDEX idx_users_deleted_at ON users(deleted_at);
```

**Audit Trail**
```sql
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(100) NOT NULL,
  record_id BIGINT NOT NULL,
  action VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  changed_by BIGINT REFERENCES users(id),
  changed_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Junction/Many-to-Many**
```sql
CREATE TABLE user_roles (
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
  role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);
```

## Indexing Strategies

### Index Types

**B-Tree (Default)**
- Best for: equality and range queries (`=`, `<`, `>`, `BETWEEN`, `LIKE 'prefix%'`)
- Default for most databases

**Hash**
- Best for: equality only (`=`)
- Faster than B-tree for exact matches
- Not supported for range queries

**GIN (PostgreSQL)**
- Best for: JSONB, arrays, full-text search
- `CREATE INDEX idx_users_tags ON users USING GIN(tags);`

**GiST (PostgreSQL)**
- Best for: geometric data, full-text search
- Range types, trigram similarity

### When to Index
- Foreign key columns
- Columns in WHERE clauses
- Columns in ORDER BY
- Columns in JOIN conditions
- Composite indexes for multi-column queries

### Composite Index Rules
- Column order matters — most selective first
- Leftmost prefix rule: index on `(a, b, c)` supports queries on `(a)`, `(a, b)`, `(a, b, c)`
- Does NOT support queries on `(b)`, `(c)`, or `(b, c)` alone
- Include columns used in ORDER BY at the end

```sql
-- For: WHERE status = 'active' AND created_at > '2024-01-01' ORDER BY created_at DESC
CREATE INDEX idx_users_status_created ON users(status, created_at DESC);
```

### Partial Indexes
```sql
-- Only index active users
CREATE INDEX idx_users_active ON users(email) WHERE status = 'active';

-- Only index non-deleted records
CREATE INDEX idx_orders_active ON orders(user_id, created_at) WHERE deleted_at IS NULL;
```

### Covering Indexes (INCLUDE)
```sql
-- Index supports query without table lookup
CREATE INDEX idx_users_email_covering ON users(email) INCLUDE (name, avatar_url);
-- Query: SELECT email, name, avatar_url FROM users WHERE email = '...'
```

### Index Maintenance
- Monitor unused indexes: `pg_stat_user_indexes`
- Remove duplicate indexes
- Reindex periodically on write-heavy tables
- Watch index size vs table size ratio

## Query Optimization

### EXPLAIN and EXPLAIN ANALYZE
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM users WHERE email = 'test@example.com';
```

**Read the Output**
- `Seq Scan` = full table scan (bad for large tables)
- `Index Scan` = using index (good)
- `Index Only Scan` = using covering index (best)
- `Bitmap Heap Scan` = multiple index ranges combined
- Look for high `cost` values and large row estimates

### Common Anti-Patterns

**SELECT ***
```sql
-- Bad
SELECT * FROM users;

-- Good
SELECT id, name, email FROM users;
```

**Functions on Indexed Columns**
```sql
-- Bad (bypasses index)
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- Good (use functional index if needed)
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';
```

**LIKE with Leading Wildcard**
```sql
-- Bad (can't use B-tree index)
SELECT * FROM users WHERE name LIKE '%john%';

-- Good (use trigram index)
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_users_name_trgm ON users USING GIN(name gin_trgm_ops);
```

**N+1 Query Problem**
```sql
-- Bad: 1 query for orders + N queries for users
SELECT * FROM orders;
-- For each order: SELECT * FROM users WHERE id = ?

-- Good: Single JOIN
SELECT o.*, u.name, u.email
FROM orders o
JOIN users u ON u.id = o.user_id;
```

**OR Conditions**
```sql
-- Bad
SELECT * FROM users WHERE status = 'active' OR status = 'pending';

-- Good
SELECT * FROM users WHERE status IN ('active', 'pending');

-- Or use UNION for different columns
SELECT * FROM users WHERE status = 'active'
UNION ALL
SELECT * FROM users WHERE role = 'admin';
```

### Query Performance Tips
- Use `LIMIT` for large result sets
- Avoid `COUNT(*)` on large tables (use approximate or cached count)
- Use `EXISTS` instead of `IN` for subqueries
- Prefer `JOIN` over subqueries when possible
- Use `UNION ALL` instead of `UNION` when duplicates aren't possible
- Batch inserts: `INSERT INTO ... VALUES (...), (...), (...)`
- Use `RETURNING` clause to get inserted data without extra query

## Transactions

### Isolation Levels

| Level              | Dirty Read | Non-Repeatable Read | Phantom Read |
|--------------------|-----------|---------------------|--------------|
| Read Uncommitted   | Possible  | Possible            | Possible     |
| Read Committed     | No        | Possible            | Possible     |
| Repeatable Read    | No        | No                  | Possible*    |
| Serializable       | No        | No                  | No           |

*PostgreSQL prevents phantom reads at Repeatable Read level

### Best Practices
- Keep transactions short
- Use lowest isolation level that works
- Handle serialization failures with retry logic
- Never hold transactions open during user interaction
- Set statement timeout to prevent runaway queries

```sql
BEGIN;
-- Set timeout for this transaction
SET LOCAL statement_timeout = '5000';

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
```

### Optimistic vs Pessimistic Locking

**Optimistic (Version Column)**
```sql
ALTER TABLE products ADD COLUMN version INT DEFAULT 0;

UPDATE products
SET stock = stock - 1, version = version + 1
WHERE id = 123 AND version = 5;
-- If 0 rows affected, someone else updated — retry
```

**Pessimistic (SELECT FOR UPDATE)**
```sql
BEGIN;
SELECT * FROM products WHERE id = 123 FOR UPDATE;
-- Other transactions wait until this one commits
UPDATE products SET stock = stock - 1 WHERE id = 123;
COMMIT;
```

## Migrations

### Principles
- Every migration must be reversible (up and down)
- Never modify data and schema in the same migration
- Test migrations on production-size data before running
- Use transactions for DDL when supported

### Safe Migration Patterns

**Adding a Column**
```sql
-- Step 1: Add column (nullable)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Deploy code that writes to new column

-- Step 3: Backfill existing data (in batches)
UPDATE users SET phone = '' WHERE phone IS NULL;

-- Step 4: Add NOT NULL constraint
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

**Renaming a Column**
```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);

-- Step 2: Deploy code that writes to both columns

-- Step 3: Backfill data
UPDATE users SET full_name = name;

-- Step 4: Deploy code that reads from new column

-- Step 5: Remove old column (in next migration)
ALTER TABLE users DROP COLUMN name;
```

**Adding an Index on Large Table**
```sql
-- PostgreSQL: Create index concurrently (non-blocking)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- MySQL: Use ALGORITHM=INPLACE, LOCK=NONE
CREATE INDEX idx_users_email ON users(email) ALGORITHM=INPLACE, LOCK=NONE;
```

### Migration Tools
- **PostgreSQL**: Flyway, Liquibase, pgmigrate, Prisma Migrate
- **MySQL**: Flyway, Liquibase, Goose
- **ORM-based**: Prisma, Sequelize, TypeORM, Django Migrations
- **Always**: Version control migrations, never edit applied migrations

## Connection Pooling

### Why Pool
- Opening connections is expensive (~20-30ms)
- Databases have connection limits
- Prevents connection exhaustion under load

### Pool Configuration
```
Min connections: 5-10
Max connections: (CPU cores * 2) + effective_spindle_count
Idle timeout: 30 seconds
Max lifetime: 30 minutes (prevents stale connections)
```

### Tools
- **PgBouncer**: PostgreSQL connection pooler
- **ProxySQL**: MySQL connection pooler + query routing
- **Application-level**: HikariCP (Java), pgbouncer, node-pool

## NoSQL vs SQL

### Use SQL (Relational) When
- Data has clear relationships
- ACID transactions required
- Complex queries with joins
- Schema is well-defined and stable
- Reporting and analytics needed

### Use NoSQL When

**Document (MongoDB, DynamoDB)**
- Flexible, evolving schema
- Hierarchical data, self-contained documents
- High write throughput
- Content management, catalogs

**Key-Value (Redis, Memcached)**
- Caching
- Session storage
- Real-time counters
- Leaderboards

**Column-Family (Cassandra, ScyllaDB)**
- Time-series data
- Write-heavy workloads
- Geographically distributed
- IoT, telemetry

**Graph (Neo4j)**
- Highly connected data
- Social networks
- Recommendation engines
- Fraud detection

## Performance Monitoring

### Key Metrics
- Query execution time (p50, p95, p99)
- Connection pool utilization
- Cache hit ratio (should be >99% for indexes)
- Table bloat (PostgreSQL: `pg_stat_user_tables`)
- Lock wait times
- Replication lag

### Slow Query Log
```sql
-- PostgreSQL
ALTER SYSTEM SET log_min_duration_statement = 200; -- Log queries > 200ms

-- MySQL
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.2;
```

## ORM Patterns

### Prisma
```prisma
// schema.prisma
model User {
  id        String   @id @default(uuid())
  name      String
  email     String   @unique
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  @@index([email])
  @@map("users")
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String?
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  tags      Tag[]
  createdAt DateTime @default(now())
  
  @@index([authorId])
  @@index([createdAt(sort: Desc)])
}
```

```typescript
// Efficient queries
const posts = await prisma.post.findMany({
  where: { authorId: userId },
  include: { author: { select: { name: true } } },
  orderBy: { createdAt: 'desc' },
  take: 20,
  skip: (page - 1) * 20,
});

// N+1 prevention with include
const users = await prisma.user.findMany({
  include: { posts: true }, // Single query with JOIN
});

// Raw queries for complex operations
const result = await prisma.$queryRaw`
  SELECT u.name, COUNT(p.id) as post_count
  FROM users u
  LEFT JOIN posts p ON u.id = p.author_id
  GROUP BY u.id
  HAVING COUNT(p.id) > 5
`;
```

### SQL Query Builder (Knex)
```typescript
import knex from 'knex';

const db = knex({ client: 'pg', connection: process.env.DATABASE_URL });

// Fluent query builder
const users = await db('users')
  .select('users.*', db.raw('COUNT(orders.id) as order_count'))
  .leftJoin('orders', 'users.id', 'orders.user_id')
  .where('users.status', 'active')
  .where('users.created_at', '>', new Date('2024-01-01'))
  .groupBy('users.id')
  .having(db.raw('COUNT(orders.id) > 5'))
  .orderBy('order_count', 'desc')
  .limit(20)
  .offset((page - 1) * 20);

// Transactions
const result = await db.transaction(async (trx) => {
  const order = await trx('orders').insert({ user_id: 1, total: 99.99 }).returning('*');
  await trx('order_items').insert([
    { order_id: order[0].id, product_id: 1, quantity: 2 },
    { order_id: order[0].id, product_id: 3, quantity: 1 },
  ]);
  await trx('inventory')
    .where('id', 1)
    .decrement('stock', 2);
  return order[0];
});
```

## Replication and Sharding

### Read Replicas
```
Primary (writes) ──async replication──> Replica 1 (reads)
                                      ──> Replica 2 (reads)
                                      ──> Replica 3 (reads, analytics)

Connection routing:
- Write queries → Primary
- Read queries → Replicas (round-robin)
- Critical reads → Primary (freshness guarantee)
```

```typescript
// Connection pool with read/write split
const writePool = createPool({ host: 'primary.db', max: 10 });
const readPool = createPool({ host: 'replica.db', max: 20 });

async function query(sql: string, params: any[], usePrimary = false) {
  const pool = usePrimary ? writePool : readPool;
  return pool.query(sql, params);
}

// Force primary for recent writes (read-your-writes consistency)
async function getUserAfterWrite(userId: string) {
  return query('SELECT * FROM users WHERE id = $1', [userId], true);
}
```

### Sharding
```
User ID 1-1000000   → Shard A (us-east)
User ID 1000001-2M  → Shard B (eu-west)
User ID 2000001-3M  → Shard C (ap-southeast)

Sharding strategies:
- Range-based: By ID range (simple, but uneven distribution)
- Hash-based: hash(key) % num_shards (even distribution)
- Geo-based: By user region (low latency)
- Directory-based: Lookup table maps key to shard (flexible)

When to shard:
- Single database exceeds vertical scaling limits
- Read/write throughput exceeds single node capacity
- Data size exceeds single node storage
- Geographic latency requirements
```

## When to Use Me

Use this skill when:
- Designing database schema
- Writing or optimizing queries
- Adding indexes
- Creating migrations
- Debugging slow queries
- Choosing between SQL and NoSQL
- Setting up connection pooling
- Planning database scaling
- Configuring read replicas or sharding
- Choosing ORM vs query builder

## Quality Checklist

- [ ] Tables follow naming conventions
- [ ] All foreign keys have indexes
- [ ] Queries use EXPLAIN to verify index usage
- [ ] No N+1 query patterns
- [ ] Transactions are short and use appropriate isolation
- [ ] Migrations are reversible and tested
- [ ] Connection pool is properly configured
- [ ] Slow query log is enabled
- [ ] Money values use DECIMAL, not FLOAT
- [ ] Timestamps include timezone
- [ ] Soft deletes have proper indexes
- [ ] No SELECT * in production code
- [ ] ORM queries use select/include to avoid over-fetching
- [ ] Read replicas configured for read-heavy workloads
- [ ] Sharding strategy defined if data exceeds single node
