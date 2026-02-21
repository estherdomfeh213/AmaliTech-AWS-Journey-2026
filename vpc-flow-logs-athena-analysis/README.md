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