---
name: data-engineering-master
description: Design and build data pipelines, warehouses, and streaming systems. Covers ETL/ELT, Spark, Airflow, data modeling, quality, CDC, and the modern data stack.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: backend
  category: backend
---

# Data Engineering Master

## What I Do

I help design and build reliable, scalable data pipelines and infrastructure. I ensure data quality, proper modeling, and efficient processing for both batch and streaming workloads.

## ETL vs ELT

### ETL (Extract, Transform, Load)
```
Source → Extract → Transform (in pipeline) → Load → Warehouse
```
- Transform before loading — processed data in warehouse
- Use when: Compliance requires data masking before storage, limited warehouse compute
- Tools: Apache NiFi, Talend, custom pipelines

### ELT (Extract, Load, Transform)
```
Source → Extract → Load (raw) → Transform (in warehouse) → Analytics
```
- Load raw data first, transform inside warehouse
- Use when: Modern cloud warehouse (Snowflake, BigQuery), need flexibility
- Tools: Fivetran, Airbyte + dbt

### Modern Data Stack
```
Fivetran/Airbyte → Snowflake/BigQuery → dbt → BI Tool
     (EL)              (Storage)       (T)      (Looker, Tableau)
```

## Data Modeling

### Star Schema
```
                    ┌─────────────┐
                    │  Fact Table │
                    │  (metrics)  │
                    └──────┬──────┘
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │Date Dim  │ │User Dim  │ │ProductDim│
        └──────────┘ └──────────┘ └──────────┘

Fact Table:
  - Contains measurements/metrics (sales, clicks, revenue)
  - Foreign keys to dimension tables
  - Additive measures (can sum across dimensions)

Dimension Tables:
  - Descriptive attributes (who, what, where, when)
  - Denormalized for query performance
  - Slowly Changing Dimensions (SCD)
```

### Slowly Changing Dimensions
```sql
-- SCD Type 1: Overwrite (no history)
UPDATE dim_user SET email = 'new@email.com' WHERE user_id = 123;

-- SCD Type 2: Add new row (full history)
UPDATE dim_user SET current = false, end_date = NOW() WHERE user_id = 123 AND current = true;
INSERT INTO dim_user (user_id, email, start_date, end_date, current)
VALUES (123, 'new@email.com', NOW(), NULL, true);

-- SCD Type 3: Add column (limited history)
UPDATE dim_user SET email = 'new@email.com', previous_email = email WHERE user_id = 123;
```

### Snowflake Schema
```
Fact → Dimension → Sub-dimension
  More normalized, less redundancy
  More joins, slower queries
  Use when: Storage cost > compute cost
```

### One Big Table (OBT)
```
All dimensions pre-joined into single wide table
  Fastest queries, no joins
  Highest storage, complex updates
  Use when: Query speed is critical, data doesn't change often
```

## Batch Processing

### Apache Spark
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum, avg, window

spark = SparkSession.builder.appName("analytics").getOrCreate()

# Read data
df = spark.read.parquet("s3://data-lake/raw/events/")

# Transform
result = (
    df
    .filter(col("event_date") >= "2024-01-01")
    .groupBy("user_id", "event_type")
    .agg(
        sum("amount").alias("total_amount"),
        avg("duration").alias("avg_duration"),
    )
    .withColumn("tier", 
        when(col("total_amount") > 1000, "premium")
        .otherwise("standard"))
)

# Write with partitioning
result.write \
    .mode("overwrite") \
    .partitionBy("tier") \
    .parquet("s3://data-lake/processed/user_metrics/")

# Partitioning best practices:
# - Partition by columns used in WHERE clauses
# - Avoid over-partitioning (too many small files)
# - Target partition size: 128MB - 1GB
# - Common: date, country, category
```

### Partitioning and Optimization
```python
# Bucketing — pre-shuffle for joins
df.write.bucketBy(16, "user_id").sortBy("timestamp").saveAsTable("events_bucketed")

# Z-Ordering — co-locate related data (Delta Lake)
df.write.format("delta").option("dataSkippingStatsColumns", "user_id,event_type").save(path)

# Compaction — merge small files
spark.sql("OPTIMIZE delta.`s3://path/` ZORDER BY (user_id)")

# File formats:
# Parquet: Columnar, best for analytics (default choice)
# ORC: Columnar, Hive ecosystem
# Avro: Row-based, best for streaming/CDC
# Delta/Iceberg/Hudi: Table formats with ACID, time travel
```

## Stream Processing

### Apache Kafka
```python
from confluent_kafka import Producer, Consumer

# Producer
producer = Producer({
    'bootstrap.servers': 'kafka:9092',
    'acks': 'all',
    'retries': 3,
    'enable.idempotence': True,  # Exactly-once
})

producer.produce(
    topic='user-events',
    key='user_123',
    value=json.dumps({'event': 'purchase', 'amount': 99.99}),
    partition=0,
)
producer.flush()

# Consumer
consumer = Consumer({
    'bootstrap.servers': 'kafka:9092',
    'group.id': 'analytics-service',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False,  # Manual commit
})

consumer.subscribe(['user-events'])
while True:
    msg = consumer.poll(1.0)
    if msg is None:
        continue
    if msg.error():
        continue
    
    event = json.loads(msg.value())
    process_event(event)
    consumer.commit(msg)  # Commit after processing
```

### Windowing
```python
# Tumbling Window — fixed, non-overlapping
window(Tumbling.over("10 minutes").on("timestamp"))

# Sliding Window — fixed, overlapping
window(Sliding.over("1 hour").every("10 minutes").on("timestamp"))

# Session Window — gap-based
window(Session.withGap("30 minutes").on("timestamp"))

# Processing time vs Event time
# Event time: When the event actually happened
# Processing time: When the event was received
# Use event time with watermarks for late data
```

### Exactly-Once Processing
```
Source: Idempotent writes or transactional reads
Processing: Exactly-once semantics (Kafka transactions, Flink checkpoints)
Sink: Idempotent writes or two-phase commit

Kafka: enable.idempotence=true + transactional.id
Flink: Checkpointing + two-phase commit sink
Spark: Write-ahead logs + idempotent output
```

## Orchestration

### Apache Airflow
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'email_on_failure': True,
}

dag = DAG(
    'daily_analytics_pipeline',
    default_args=default_args,
    schedule='0 2 * * *',  # Daily at 2 AM
    start_date=datetime(2024, 1, 1),
    catchup=False,
    max_active_runs=1,
)

def extract_data():
    # Extract from source
    pass

def transform_data():
    # Transform with Spark/dbt
    pass

def load_data():
    # Load to warehouse
    pass

extract = PythonOperator(task_id='extract', python_callable=extract_data, dag=dag)
transform = PythonOperator(task_id='transform', python_callable=transform_data, dag=dag)
load = PythonOperator(task_id='load', python_callable=load_data, dag=dag)

extract >> transform >> load

# Sensors — wait for external conditions
wait_for_source = ExternalTaskSensor(
    task_id='wait_for_source_data',
    external_dag_id='source_pipeline',
    external_task_id='complete',
    dag=dag,
)

wait_for_source >> extract
```

### Airflow Best Practices
- Idempotent tasks (safe to retry)
- Set appropriate retries and timeouts
- Use sensors instead of time.sleep()
- Parameterize with templates
- Monitor task duration trends
- Use XCom sparingly (small metadata only)
- Separate DAG definition from task logic

## Data Lakes and Warehouses

### Data Lake Architecture
```
s3://data-lake/
├── raw/              # Immutable, source format
│   ├── events/
│   ├── users/
│   └── orders/
├── staged/           # Cleaned, standardized
│   ├── events/
│   └── users/
├── processed/        # Transformed, analytics-ready
│   ├── daily_metrics/
│   └── user_segments/
└── curated/          # Business-ready, documented
    ├── fact_sales/
    └── dim_users/
```

### Warehouse Comparison
| Feature | Snowflake | BigQuery | Redshift |
|---------|-----------|----------|----------|
| Architecture | Separated compute/storage | Serverless | MPP clusters |
| Scaling | Auto-scales warehouses | Fully managed | Manual/auto |
| Data formats | Native + external | Native + external | Native |
| Semi-structured | VARIANT (JSON) | JSON, nested | SUPER |
| Time travel | Yes (up to 90 days) | Yes (up to 7 days) | No |
| Pricing | Credits + storage | On-demand + slots | Node hours |

## Data Quality

### Great Expectations
```python
import great_expectations as gx

context = gx.get_context()
validator = context.get_validator(
    batch_request={"datasource_name": "warehouse", "data_asset_name": "users"}
)

validator.expect_column_values_to_not_be_null("user_id")
validator.expect_column_values_to_be_unique("user_id")
validator.expect_column_values_to_match_regex("email", r"^[^@]+@[^@]+\.[^@]+$")
validator.expect_column_values_to_be_between("age", min_value=0, max_value=150)
validator.expect_table_row_count_to_be_between(min_value=1000)

results = validator.validate()
if not results["success"]:
    raise DataQualityError(f"Validation failed: {results}")
```

### Data Quality Checks
```sql
-- Completeness
SELECT COUNT(*) as total, 
       COUNT(email) as with_email,
       COUNT(name) as with_name
FROM users;

-- Freshness
SELECT MAX(updated_at) as last_update
FROM orders
HAVING MAX(updated_at) < NOW() - INTERVAL '24 hours';

-- Consistency
SELECT order_id
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- Distribution
SELECT 
    percentile_cont(0.5) WITHIN GROUP (ORDER BY amount) as p50,
    percentile_cont(0.95) WITHIN GROUP (ORDER BY amount) as p95,
    percentile_cont(0.99) WITHIN GROUP (ORDER BY amount) as p99
FROM transactions;
```

## CDC (Change Data Capture)

### Debezium
```
PostgreSQL → WAL → Debezium → Kafka → Consumers
                                    ↓
                            ┌───────┼───────┐
                            ▼       ▼       ▼
                        Search   Cache  Analytics
                        Index   Update  Pipeline
```

```json
// Debezium event
{
  "before": { "id": 123, "status": "pending", "updated_at": "2024-01-15T10:00:00Z" },
  "after": { "id": 123, "status": "completed", "updated_at": "2024-01-15T10:05:00Z" },
  "source": { "table": "orders", "db": "production", "ts_ms": 1705312500000 },
  "op": "u",
  "ts_ms": 1705312500100
}
```

### CDC Best Practices
- Use log-based CDC (not query-based) for performance
- Handle schema changes gracefully
- Monitor lag between source and sink
- Implement dead letter queue for failed events
- Use idempotent consumers

## Data Governance

### Data Lineage
```
Source DB → Kafka → Spark → Snowflake → dbt → Looker
                                    ↓
                              Data Catalog
                              (Amundsen, DataHub)
```

### Catalog Metadata
```yaml
Table: fact_orders
Owner: analytics-team
Description: Daily order metrics
Source: orders table (CDC) + payments table (batch)
Refresh: Daily at 3 AM UTC
SLA: Available by 6 AM UTC
PII: No
Retention: 7 years
Quality Checks: 12 passing
Downstream: revenue_dashboard, executive_report
```

## When to Use Me

Use this skill when:
- Designing data pipelines (batch or streaming)
- Choosing between ETL and ELT
- Setting up Airflow DAGs
- Modeling data warehouses
- Implementing data quality checks
- Setting up CDC pipelines
- Choosing data storage solutions
- Building data lake architectures

## Quality Checklist

- [ ] Raw data stored immutably
- [ ] Pipeline tasks are idempotent
- [ ] Data quality checks on all critical tables
- [ ] Schema evolution handled (backward compatible)
- [ ] Partitioning strategy defined
- [ ] Monitoring and alerting on pipeline failures
- [ ] Data freshness checks in place
- [ ] PII identified and protected
- [ ] Data catalog maintained
- [ ] Retry logic with exponential backoff
- [ ] Dead letter queue for failed records
- [ ] Documentation for all tables and pipelines
