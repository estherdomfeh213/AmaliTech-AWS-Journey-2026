# Query VPC Flow Logs Using Amazon Athena

A comprehensive project demonstrating how to capture, store, and analyze VPC network traffic using VPC Flow Logs and Amazon Athena for serverless querying.


![architecture diagram](architecture-diagrams/architecture-diagram.png)


## Project Objectives

- Create a custom VPC with public subnet and internet gateway
- Configure VPC Flow Logs to capture network traffic
- Set up S3 bucket with proper permissions for log storage
- Launch EC2 instance and generate web traffic
- Use AWS Glue to catalog and prepare data for querying
- Query network traffic data using Amazon Athena
- Analyze VPC flow logs to gain insights into network patterns

##  Infrastructure Components
|Component |Name |Configuration | Purpose| 
|-----|----|----|-----|
|VPC | MyVPC  |192.168.0.0/26  | Isolated network environment |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |





### Network Configuration
### Compute & Storage
### Analytics Services




## Step-by-Step Implementation

### Phase 1: Storage Foundation

#### Task 2: Create S3 Bucket with Log Delivery Policy
```bash 
# Bucket Configuration:
Bucket Name: athena-whizlabs
Region: us-east-1
Block Public Access: UNCHECKED (✓ Acknowledge)
```

**Apply Bucket Policy**
```json 
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::athena-whizlabs/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "AWSLogDeliveryCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": [
        "s3:GetBucketAcl",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::athena-whizlabs"
    }
  ]
}
```

**Why this matters:** This policy allows the VPC Flow Logs service to write directly to your S3 bucket. Without it, flow logs will fail to deliver.

### Phase 2: Network Infrastructure
#### Task 3-4: Create VPC and Internet Gateway

```bash 
# VPC Configuration
VPC Name: MyVPC
CIDR: 192.168.0.0/26  # 64 IP addresses (62 usable)
Tenancy: Default

# Internet Gateway
IGW Name: MyInternetGateway
Attachment: MyVPCS
```
**CIDR Choice:** 192.168.0.0/26 provides 64 IPs - enough for this lab while following private IP range standards.

#### Task 5-7: Create and Configure Public Subnet
```bash 
# Public Subnet
Subnet Name: Public Subnet
AZ: us-east-1a
CIDR: 192.168.0.1/27  # 32 IPs (30 usable)
Auto-assign Public IP: Enabled

# Public Route Table
Route Table: PublicRouteTable
VPC: MyVPC
Routes:
  - Destination: 0.0.0.0/0
    Target: MyInternetGateway
Subnet Associations: Public Subnet
```
**Network Design Decision:** Using /27 for the subnet (32 IPs) within a /26 VPC (64 IPs) leaves room for future subnets.

#### Task 8: Create VPC Flow Log
```bash 
# Flow Log Configuration
Name: MyVPCFlowLog
Filter: All (accepts and rejects)
Maximum Aggregation Interval: 1 minute
Destination: Send to Amazon S3 Bucket
S3 Bucket ARN: arn:aws:s3:::athena-whizlabs
Log Record Format: AWS default format
```
**Why 1-minute interval?** Provides near-real-time visibility while keeping costs reasonable. Default is 10 minutes.

### Phase 3: Compute & Traffic Generation
#### Task 9: Launch EC2 Instance
```bash 
# Instance Configuration
Name: MyEC2Instance
AMI: Amazon Linux 2023
Type: t2.micro
Key Pair: MyEC2FLowLogsKey (Create new)

Network Settings:
  VPC: MyVPC
  Subnet: Public Subnet
  Auto-assign Public IP: Enable
  Security Group: FlowLog-SG (new)
    - SSH, Port 22, Source: 0.0.0.0/0
    - HTTP, Port 80, Source: 0.0.0.0/0
```

#### Task 10-11: Generate Traffic
```bash 
# SSH into instance
ssh -i "MyEC2FLowLogsKey.pem" ec2-user@<Public-IP>

# Install Apache web server
sudo su
dnf -y update
dnf install -y httpd
cd /var/www/html
echo "Response coming from server" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# Verify in browser
http://<Public-IP>  # Should show "Response coming from server"
```

**Traffic Generated:**
- SSH connection (port 22) - your connection
- HTTP requests (port 80) - browser access
- DNS queries - for package updates
- VPC internal traffic

#### Task 11 (continued): Verify Logs in S3
```bash 
# After ~5 minutes, check S3 bucket structure:
s3://athena-whizlabs/
└── AWSLogs/
    └── <12-digit-account-id>/
        └── vpcflowlogs/
            └── us-east-1/
                └── 2026/
                    └── 02/
                        └── 19/
                            └── *.gz files
```

### Phase 4: Data Cataloging with AWS Glue
#### Task 12: Create Glue Database and Table

**Step 1: Create Database**
```sql 
-- In AWS Glue Console
Database Name: whizdb
Location: (empty for managed)
```

**Step 2: Create Table with JSON Schema**
```json 
[
  {
    "Name": "version",
    "Type": "string"
  },
  {
    "Name": "account_id",
    "Type": "int"
  },
  {
    "Name": "interface_id",
    "Type": "string"
  },
  {
    "Name": "srcaddr",
    "Type": "string"
  },
  {
    "Name": "dstaddr",
    "Type": "string"
  },
  {
    "Name": "srcport",
    "Type": "int"
  },
  {
    "Name": "dstport",
    "Type": "int"
  },
  {
    "Name": "protocol",
    "Type": "int"
  },
  {
    "Name": "packets",
    "Type": "int"
  },
  {
    "Name": "bytes",
    "Type": "int"
  },
  {
    "Name": "start",
    "Type": "int"
  },
  {
    "Name": "end",
    "Type": "int"
  },
  {
    "Name": "action",
    "Type": "string"
  },
  {
    "Name": "log_status",
    "Type": "string"
  }
]
```
**Understanding the Schema:**