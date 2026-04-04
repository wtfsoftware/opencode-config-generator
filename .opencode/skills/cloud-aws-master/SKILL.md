---
name: cloud-aws-master
description: Design and deploy cloud infrastructure on AWS following best practices. Covers compute, storage, databases, networking, IAM, infrastructure as code, and cost optimization.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: devops
  category: devops
---

# Cloud AWS Master

## What I Do

I help design and deploy secure, scalable, and cost-effective AWS infrastructure. I apply AWS best practices for architecture, security, and operational excellence.

## Compute

### EC2
```yaml
# Key configurations
Instance Types:
  - General Purpose: t3, m6i (balanced CPU/memory)
  - Compute Optimized: c6i (high CPU workloads)
  - Memory Optimized: r6i, x2idn (databases, in-memory)
  - Storage Optimized: i4i, d3 (high IOPS, throughput)

Pricing:
  - On-Demand: Pay by second, no commitment
  - Reserved: 1-3 year commitment, up to 72% savings
  - Spot: Up to 90% savings, can be interrupted
  - Savings Plans: Commit to $/hour, flexible

Best Practices:
  - Use IAM roles instead of access keys
  - Enable detailed monitoring for production
  - Use Auto Scaling groups for availability
  - Store data on EBS, not instance store (unless ephemeral OK)
  - Use User Data for bootstrapping, not configuration management
```

### Lambda
```typescript
// Serverless function
export const handler = async (event: APIGatewayEvent) => {
  try {
    const body = JSON.parse(event.body || '{}');
    const result = await processRequest(body);
    
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' }),
    };
  }
};

// Lambda best practices
// - Keep deployment packages small (<250MB unzipped)
// - Use Lambda layers for shared dependencies
// - Set appropriate memory (also affects CPU)
// - Use provisioned concurrency for latency-sensitive workloads
// - Set timeouts appropriately (max 15 minutes)
// - Use environment variables for configuration
// - Implement idempotency for retry safety
```

### ECS/EKS
```yaml
# ECS Fargate — serverless containers
TaskDefinition:
  Cpu: 512
  Memory: 1024
  NetworkMode: awsvpc
  RequiresCompatibilities: [FARGATE]

Service:
  DesiredCount: 3
  LaunchType: FARGATE
  HealthCheckGracePeriodSeconds: 30

# When to choose what:
# ECS Fargate: Simple, AWS-native, lower ops overhead
# EKS: Kubernetes ecosystem, multi-cloud, complex workloads
# ECS EC2: Cost optimization at scale, full control
```

## Storage

### S3
```yaml
S3 Best Practices:
  - Enable versioning for data protection
  - Use lifecycle policies to transition to cheaper tiers
  - Enable default encryption (SSE-S3 or SSE-KMS)
  - Block public access by default
  - Use S3 Transfer Acceleration for global uploads
  - Enable access logging
  - Use pre-signed URLs for temporary access
  - Implement object lock for compliance

Lifecycle Policy:
  - Current version:
    - 0-30 days: S3 Standard
    - 30-90 days: S3 Standard-IA
    - 90-365 days: S3 One Zone-IA
    - 365+ days: S3 Glacier Deep Archive
  - Previous versions: Transition to Glacier after 30 days
  - Expire: Delete after 7 years (compliance)
```

### EBS vs EFS
```
EBS (Elastic Block Store):
  - Block storage, single AZ
  - Attach to one EC2 instance (multi-attach for specific types)
  - Types: gp3 (general), io2 (high IOPS), st1 (throughput)
  - Use for: Databases, boot volumes, low-latency needs

EFS (Elastic File System):
  - File storage (NFS), multi-AZ
  - Shared across many EC2 instances
  - Use for: Content management, shared data, home directories
  - More expensive than EBS
```

## Database

### RDS
```yaml
RDS Engines:
  - PostgreSQL: Best all-around, JSONB support
  - MySQL: Web applications, familiar
  - Aurora: AWS-optimized, 5x MySQL / 3x PostgreSQL performance
  - MariaDB: MySQL-compatible, open-source
  - SQL Server: Enterprise, Windows ecosystem
  - Oracle: Enterprise, legacy applications

Best Practices:
  - Use Multi-AZ for production (automatic failover)
  - Read Replicas for read-heavy workloads
  - Enable automated backups (point-in-time recovery)
  - Use parameter groups for configuration
  - Enable Performance Insights
  - Use IAM authentication instead of passwords
  - Encrypt at rest (KMS) and in transit (SSL/TLS)
```

### DynamoDB
```typescript
// NoSQL, single-digit millisecond latency
// Best for: High-scale key-value, session storage, gaming

// Design patterns:
// 1. Single Table Design — multiple entity types in one table
// 2. Use GSIs for alternate access patterns
// 3. Denormalize data — joins are not supported

// Access patterns drive table design
// PK: USER#<userId>
// SK: ORDER#<orderId>

// Query: All orders for a user
{
  TableName: "Orders",
  KeyConditionExpression: "PK = :pk AND begins_with(SK, :sk)",
  ExpressionAttributeValues: {
    ":pk": "USER#123",
    ":sk": "ORDER#"
  }
}

// Best Practices:
// - Choose partition key with high cardinality
// - Avoid hot partitions
// - Use on-demand capacity for unpredictable workloads
// - Use TTL for automatic expiration
// - Use DynamoDB Streams for change capture
```

### ElastiCache
```
Redis:
  - Caching layer (reduce database load)
  - Session storage
  - Real-time analytics
  - Pub/Sub messaging
  - Leaderboards (sorted sets)

Memcached:
  - Simple caching
  - Multi-threaded (better for simple key-value)
  - No persistence, no replication

Best Practices:
  - Place in same VPC as application
  - Use cluster mode for large datasets
  - Enable encryption in transit and at rest
  - Monitor hit/miss ratio (target >90%)
  - Set appropriate TTL for cached data
```

## Networking

### VPC Architecture
```
VPC: 10.0.0.0/16
├── Public Subnets (10.0.0.0/24, 10.0.1.0/24)
│   ├── Route: 0.0.0.0/0 → Internet Gateway
│   └── Resources: Load Balancers, NAT Gateways
│
├── Private App Subnets (10.0.2.0/24, 10.0.3.0/24)
│   ├── Route: 0.0.0.0/0 → NAT Gateway
│   └── Resources: Application Servers
│
├── Private Data Subnets (10.0.4.0/24, 10.0.5.0/24)
│   ├── No route to internet
│   └── Resources: Databases, ElastiCache
│
└── VPC Endpoints (Gateway/Interface)
    ├── S3 Gateway Endpoint
    └── DynamoDB Gateway Endpoint
```

### Key Components
```
Internet Gateway (IGW): Connects VPC to internet
NAT Gateway: Allows outbound internet from private subnets
Security Groups: Stateful, instance-level firewall
NACLs: Stateless, subnet-level firewall (optional)
VPC Peering: Connect two VPCs
Transit Gateway: Hub for multiple VPCs
Route 53: DNS service with health checks
```

## IAM

### Principles
```yaml
Least Privilege:
  - Grant only permissions needed
  - Use specific resource ARNs, not *
  - Use conditions to restrict access
  - Review permissions regularly

IAM Structure:
  - Root account: Enable MFA, never use for daily tasks
  - IAM Users: Individual developers/admins
  - IAM Groups: Collections of users with same permissions
  - IAM Roles: For services, cross-account access, temporary access
  - IAM Policies: JSON documents defining permissions

Policy Example:
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::my-bucket/*",
    "Condition": {
      "StringEquals": {
        "aws:RequestedRegion": "us-east-1"
      }
    }
  }]
}
```

### Best Practices
- Enable MFA on root and all IAM users
- Use IAM Roles for EC2, Lambda, ECS tasks
- Rotate access keys regularly (or eliminate them)
- Use AWS Organizations for multi-account management
- Enable CloudTrail for audit logging
- Use SCPs (Service Control Policies) for guardrails

## Infrastructure as Code

### CloudFormation
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Web application stack

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]
    Default: dev

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Sub ${AWS::StackName}-vpc

  AppBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub ${AWS::StackName}-${AWS::AccountId}-app
      VersioningConfiguration:
        Status: Enabled
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

Outputs:
  VPCId:
    Value: !Ref VPC
    Export:
      Name: !Sub ${AWS::StackName}-VPCId
```

### AWS CDK (TypeScript)
```typescript
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as rds from 'aws-cdk-lib/aws-rds';

export class AppStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // VPC
    const vpc = new ec2.Vpc(this, 'AppVpc', {
      maxAzs: 3,
      natGateways: 1,
    });

    // ECS Cluster
    const cluster = new ecs.Cluster(this, 'AppCluster', { vpc });

    // RDS
    const database = new rds.DatabaseInstance(this, 'Database', {
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_16,
      }),
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T3,
        ec2.InstanceSize.MEDIUM
      ),
      vpc,
      multiAz: true,
      storageEncrypted: true,
    });

    // ECS Service
    const taskDefinition = new ecs.FargateTaskDefinition(this, 'TaskDef', {
      memoryLimitMiB: 512,
      cpu: 256,
    });

    taskDefinition.addContainer('App', {
      image: ecs.ContainerImage.fromAsset('.'),
      portMappings: [{ containerPort: 3000 }],
      environment: {
        DATABASE_URL: database.secret?.secretValue.toString() || '',
      },
    });
  }
}
```

## Cost Optimization

### Strategies
```
1. Right-sizing: Match instance type to actual usage
   - Use CloudWatch metrics to identify over-provisioned resources
   - Downsize instances with <20% CPU utilization

2. Reserved Instances / Savings Plans:
   - Compute Savings Plans: 1-3 year, up to 66% savings
   - EC2 Instance Savings Plans: Specific family, up to 72%
   - Standard RIs: Specific instance, up to 75%

3. Spot Instances:
   - Up to 90% savings
   - Use for fault-tolerant, stateless workloads
   - Implement checkpointing for state

4. Storage Optimization:
   - Lifecycle policies for S3
   - Delete unattached EBS volumes
   - Use gp3 instead of gp2 (20% cheaper, better performance)

5. Database Optimization:
   - Use Aurora Serverless for variable workloads
   - Delete unused snapshots
   - Use read replicas instead of larger instances

6. Monitoring:
   - AWS Cost Explorer for analysis
   - AWS Budgets for alerts
   - Cost Allocation Tags for tracking
   - Trusted Advisor for recommendations
```

## Serverless Patterns

### Event-Driven Architecture
```
S3 Upload → S3 Event → Lambda → Process → DynamoDB
                                    ↓
                              SNS Topic → Email/SMS
                                    ↓
                              SQS Queue → Lambda → External API

API Gateway → Lambda → DynamoDB
     ↓
  CloudWatch → Alarms → SNS → Email
```

### Step Functions
```typescript
// Orchestrate complex workflows
const definition = new sfn.Chain(start(new sfn.Pass(this, 'Start')))
  .next(new tasks.LambdaInvoke(this, 'ValidateOrder', {
    lambdaFunction: validateFn,
  }))
  .next(new sfn.Choice(this, 'IsValid')
    .when(sfn.Condition.booleanEquals('$.Payload.valid', true),
      new tasks.LambdaInvoke(this, 'ProcessPayment', { lambdaFunction: paymentFn })
        .next(new tasks.LambdaInvoke(this, 'UpdateInventory', { lambdaFunction: inventoryFn }))
    )
    .otherwise(new sfn.Fail(this, 'OrderInvalid'))
  );
```

## When to Use Me

Use this skill when:
- Designing AWS architecture
- Setting up VPC and networking
- Configuring IAM policies and roles
- Writing CloudFormation or CDK
- Choosing between AWS services
- Optimizing AWS costs
- Implementing serverless architectures
- Setting up monitoring and alerting

## Quality Checklist

- [ ] MFA enabled on root and all IAM users
- [ ] Least privilege IAM policies
- [ ] No public S3 buckets (unless intentional)
- [ ] All data encrypted at rest and in transit
- [ ] CloudTrail enabled in all regions
- [ ] Multi-AZ for production databases
- [ ] Auto Scaling configured for compute
- [ ] VPC endpoints for AWS services (no NAT for S3/DynamoDB)
- [ ] Resource tagging for cost tracking
- [ ] Budgets and alarms configured
- [ ] Infrastructure defined as code (CDK/CloudFormation)
- [ ] Backup and disaster recovery plan
