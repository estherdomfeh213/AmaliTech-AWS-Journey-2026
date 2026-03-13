# Amazon RDS Multi-AZ & Read Replica: High Availability Database Architecture with Failover Simulation

## Overview

**The Business Problem:**
Database downtime costs enterprises an average of **$5,600 per minute** according to Gartner. For mission-critical applications, a single database failure can mean lost transactions, frustrated users, and permanent revenue loss. Traditional single-instance databases represent a critical single point of failure in cloud architectures.

**The Solution:**
This project implements a **highly available Amazon Aurora MySQL database** with Multi-AZ deployment and automated failover. By leveraging AWS RDS, we eliminate the operational overhead of self-managed database clustering while achieving:

- **99.99% availability** through automatic failover to standby replica
- **Zero data loss** with synchronous replication to standby instance
- **Automatic recovery** without manual intervention
- **Read scaling** capability using reader endpoints

**Key Outcomes:**
- ✅ Successfully simulated primary instance failure with < 60-second failover
- ✅ Verified complete data durability (no data loss after failover)
- ✅ Demonstrated read/write splitting across 2 Availability Zones
- ✅ Achieved enterprise-grade HA pattern for < $150/month (development tier)

---

## Architecture
![architecture diagram](diagrams/architecture-diagram.png)

### Core Components

| Component | Configuration | Purpose |
|-----------|--------------|---------|
| **Amazon Aurora Cluster** | MySQL-compatible, Multi-AZ | Managed, highly available database |
| **Primary Instance (Writer)** | db.t3.medium, us-east-1a | Handles all write operations, DDL statements |
| **Aurora Replica (Reader)** | db.t3.medium, us-east-1c | Handles read traffic, failover target |
| **Cluster Endpoint** | `myauroracluster.cluster-xxx.rds.amazonaws.com` | Always points to current writer |
| **Reader Endpoint** | `myauroracluster.cluster-ro-xxx.rds.amazonaws.com` | Load balances across read replicas |
| **EC2 Bastion (MyRdsEc2server)** | t2.micro, Amazon Linux 2023 | Secure access point for database operations |
| **Security Groups** | `rds-maz-SG`, `MyEC2Server_SG` | Network access control |

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Aurora over standard MySQL** | 6-way replicated storage, faster failover, better performance |
| **Multi-AZ deployment** | Automatic failover across AZs eliminates single point of failure |
| **db.t3.medium instance** | Burstable performance for dev/test, cost-effective |
| **Separate security groups** | Defense in depth, least privilege access |
| **Publicly accessible (for lab)** | Enables learning, but production would use private subnets |

---

## Implementation

### Prerequisites
- AWS Account with appropriate permissions
- SSH client (or EC2 Instance Connect)
- Basic SQL knowledge

### Phase 1: EC2 Bastion Setup

**EC2 Instance Details:**
- Name: MyRdsEc2server
- AMI: Amazon Linux 2023 (kernel-6.1)
- Type: t2.micro
- Key Pair: MySSHKey.pem
- Auto-assign Public IP: Enable

**Security Group (MyEC2Server_SG):**
| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| SSH | TCP | 22 | 0.0.0.0/0 | Administrative access |

**User Data Script (Automated MySQL Installation):**
```bash
#!/bin/bash
wget https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
sudo dnf install mysql80-community-release-el9-5.noarch.rpm -y
sudo dnf repolist enabled | grep "mysql.*-community.*"
sudo dnf install mysql -y
```

### Phase 2: RDS Security Group
**Create rds-maz-SG:**
| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| MySQL/Aurora | TCP | 3306 | 0.0.0.0/0 | Initial wide open (will restrict later)



### Phase 3: Amazon Aurora Cluster Deployment
```yaml
Creation Method: Standard Create
Engine: Amazon Aurora (MySQL Compatible)

Cluster Settings:
  DB Cluster Identifier: MyAuroraCluster
  Master Username: WhizlabsAdmin
  Master Password: Whizlabs123

Instance Configuration:
  DB Instance Class: db.t3.medium
  Multi-AZ Deployment: ✓ Enabled

Connectivity:
  VPC: Default VPC
  Publicly Accessible: Yes
  Security Groups: rds-maz-SG (remove default)
  
Additional Configuration:
  Initial Database Name: whizlabsrds
  Encryption: Disabled (Lab - enable in production)
```
**Deployment Timeline:** 10-15 minutes


### Phase 4: Post-Deployment Verification
**Capture Endpoints:**
```bash 
WRITER_ENDPOINT="myauroracluster.cluster-xxxxx.us-east-1.rds.amazonaws.com"
READER_ENDPOINT="myauroracluster.cluster-ro-xxxxx.us-east-1.rds.amazonaws.com"
```

### Phase 5: Secure EC2-RDS Connectivity
**Get EC2 Private IP:*

```bash 
PRIVATE_IP="172.31.x.x"  # From EC2 console
```

**Update RDS Security Group:**
| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| MySQL/Aurora | TCP | 3306 | [EC2 Private IP]/32 | EC2 bastion access


### Phase 6: Database Operations via EC2 Bastion

**Connect to EC2:**
```bash 
ssh -i MySSHKey.pem ec2-user@<EC2-PUBLIC-IP>
sudo su -
```
**Connect to RDS Writer:**
```bash 
mysql -h myauroracluster.cluster-xxxxx.us-east-1.rds.amazonaws.com -u WhizlabsAdmin -p
# Password: Whizlabs123
```

**Database Setup:**
```sql 
-- Create and use database
CREATE DATABASE auroro_db;
USE auroro_db;

-- Create table
CREATE TABLE students (
    subject_id INT AUTO_INCREMENT,
    subject_name VARCHAR(255) NOT NULL,
    teacher VARCHAR(255),
    start_date DATE,
    lesson TEXT,
    PRIMARY KEY (subject_id)
);

-- Insert data
INSERT INTO students(subject_name, teacher) VALUES 
    ('English', 'John Taylor'),
    ('Science', 'Mary Smith'),
    ('Maths', 'Ted Miller'),
    ('Arts', 'Suzan Carpenter');

-- Verify
SELECT * FROM students;

```


### Phase 7: Multi-AZ Failover Simulation
**Initiate Failover:**
    - AWS Console → RDS → Databases → Select writer → Actions → Failover → Confirm


**What happens during failover:**
1. RDS automatically redirects connections to new writer
2. DNS records update to point cluster endpoint to new primary
3. Old primary reboots and becomes new replica
4. Process typically completes in 30-60 seconds

### Phase 8: Post-Failover Validation
**Connect to New Writer:**
```bash 
mysql -h myauroracluster.cluster-xxxxx.us-east-1.rds.amazonaws.com -u WhizlabsAdmin -p
```

**Verify Data Durability:**
```sql
SHOW DATABASES;
USE auroro_db;
SELECT * FROM students;  -- All 4 records should be present

-- Test write capability
INSERT INTO students(subject_name, teacher) VALUES ('History', 'Robert Johnson');
SELECT * FROM students WHERE teacher = 'Robert Johnson';
```


### Phase 9: Clean Up Resources

**Terminate EC2:**
- EC2 Console → Instances → Select MyRdsEc2server → Instance State → Terminate

**Delete RDS Cluster (Reader FIRST, then Writer):**
- RDS → Databases → Select reader → Actions → Delete
    - Uncheck "Create final snapshot"
    - Type "delete me"

- Repeat for writer instance


### 🔄 Comparison: Aurora Multi-AZ vs Alternatives
| Feature | Aurora Multi-AZ | Standard RDS Multi-AZ| Self-Managed| 
|------|----------|------|--------|---------|
| Failover Time | 30-60 seconds| 1-2 minutes  | Minutes to hours 
|Data Loss Risk  |None | None | Varies  
| Read Scaling |   Yes    | No  | Manual setup
| Management | Fully managed  | Fully managed  |  You manage 
|Cost  | Higher | Lower  | Your infrastructure







### Project Structure 
```text 
amazon-rds-multi-az-failover/
│
├── README.md
│
├── diagrams/
│   ├── architecture-diagram.png
│ 
│
├── documentation/
│   ├── deployment-guide.md
│   ├── failover-testing-results.md
│   └── troubleshooting-notes.md
│
├── scripts/
│   ├── setup-ec2-userdata.sh
│   ├── database-operations.sql
│   └── verify-failover.sh
│
└── screenshots/
    ├── 01-ec2-launch.png
    ├── 02-rds-creation.png
    ├── 03-database-connected.png
    ├── 04-data-inserted.png
    ├── 05-failover-initiated.png
    ├── 06-failover-complete.png
    └── 07-post-failover-data.png
```