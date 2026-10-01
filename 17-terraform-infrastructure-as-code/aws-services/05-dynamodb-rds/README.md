# AWS Database Services: DynamoDB & RDS

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

AWS splits managed databases into two fundamentally different models: DynamoDB (NoSQL, AWS's own distributed design) and RDS (relational, managed versions of familiar database engines). The right choice depends on the access pattern, not just a preference between SQL and NoSQL.

## DynamoDB

### NoSQL

DynamoDB is a key-value and document database: there is no fixed schema across items, no joins, and no SQL. Throughput and latency stay consistent (typically single-digit milliseconds) regardless of table size, because every query is required to go through an index, the partition key at minimum, rather than ever scanning the whole table by default.

### Tables

A table is the top-level container, conceptually similar to an S3 bucket or a SQL table, but schemaless beyond its key definition. Only the key structure is fixed at creation; everything else about an item's shape can vary freely.

### Items

An item is a single record in a table, DynamoDB's equivalent of a row, identified uniquely by its key.

### Attributes

Attributes are an item's fields, DynamoDB's equivalent of columns, except different items in the same table can have entirely different attributes. One order item might have a `discount_code` attribute; another, otherwise identical in shape, might not, and that is entirely valid.

### Partition key

The partition key is the primary identifier DynamoDB uses to decide which physical storage partition an item lives on, and it is also the main unit of query performance: items sharing a partition key are grouped together, and DynamoDB's performance guarantees rest on partition keys being chosen so that traffic spreads evenly across many of them rather than piling onto one hot key.

### Sort key

An optional second part of the primary key. With both a partition key and a sort key, many items can share the same partition key as long as each has a distinct sort key, which is how a one-to-many relationship (for example, one `customer_id` partition key holding many `order_id` sort keys) is modeled without a join.

### Use cases

Session storage, shopping carts, IoT device state, leaderboards and gaming data, and anything else with a simple, predictable access pattern (fetch by known key) at very large or unpredictable scale.

## RDS

### Relational database

RDS is managed infrastructure for running an actual relational database engine: AWS handles patching, backups, and failover, while the engine underneath still behaves like a normal SQL database, with real schemas, joins, and transactions, unlike DynamoDB.

### Supported engines

MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Amazon Aurora (AWS's own MySQL- and PostgreSQL-compatible engine, built for higher throughput and faster replication than stock MySQL/PostgreSQL on comparable hardware).

### DB instances

A DB instance is the actual running database server, sized by instance class (similar in spirit to EC2 instance types) and allocated storage. Unlike a self-managed database on an EC2 instance, the underlying host is never directly accessible; everything is managed through the RDS API and console instead of SSH.

### Security

DB instances live inside a VPC (see the [VPC writeup](../04-vpc/README.md)), typically in private subnets with no public IP, reachable only from application servers in the same VPC through a security group rule. Encryption at rest can be enabled at creation; encryption in transit is handled via SSL/TLS connections to the engine.

### Backups

RDS takes automated daily backups during a configurable backup window and retains transaction logs between them, enabling point-in-time restore to any second within the retention period, not just to the most recent daily snapshot. Manual snapshots can also be taken on demand and kept indefinitely, independent of the automated retention window.

### Multi-AZ

A Multi-AZ deployment keeps a synchronously replicated standby copy of the database in a second Availability Zone. If the primary fails, RDS fails over to the standby automatically, with no application reconfiguration needed, since failover updates the same DNS endpoint the application already connects to. This is for availability, not read scaling; the standby does not serve read traffic.

### Read replicas

A read replica is an asynchronously replicated, separate copy of the database that can serve read-only queries, offloading read traffic from the primary. Unlike a Multi-AZ standby, a read replica is actively queryable and can be promoted to a standalone writable database if needed, but ordinary replication lag means it can briefly lag behind the primary; it is for scaling reads, not for high availability on its own.

### Use cases

Any application needing real relational guarantees: foreign keys, multi-table transactions, complex joins, existing SQL-based application code being lifted into the cloud rather than rewritten against a NoSQL model.

## DynamoDB vs. RDS: when to use which

| | DynamoDB | RDS |
|---|---|---|
| Data model | Key-value / document, schemaless | Relational, fixed schema |
| Scaling | Near-automatic, partition-based | Vertical (instance size) or read replicas |
| Query flexibility | Limited to key-based access patterns (plus secondary indexes) | Full SQL: joins, aggregates, ad hoc queries |
| Best fit | High-scale, predictable access patterns | Complex relationships, transactions, existing SQL workloads |
