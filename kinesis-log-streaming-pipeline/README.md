# Real-Time Log Streaming Pipeline with Amazon Kinesis
## End-to-End Data Streaming Project
![AWS](https://img.shields.io/badge/AWS-Kinesis%20Pipeline-FF9900?style=for-the-badge&logo=amazonaws)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Services](https://img.shields.io/badge/Services-Kinesis%20%7C%20EC2%20%7C%20S3%20%7C%20Firehose-blue?style=for-the-badge)

--

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture Diagram](#architecture-diagram)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Implementation Steps](#implementation-steps)
  - [1. EC2 Instance Setup](#1-ec2-instance-setup)
  - [2. Host Sample Website](#2-host-sample-website)
  - [3. Configure Log Permissions](#3-configure-log-permissions)
  - [4. Create Kinesis Data Stream](#4-create-kinesis-data-stream)
  - [5. Create S3 Bucket](#5-create-s3-bucket)
  - [6. Create Kinesis Data Firehose](#6-create-kinesis-data-firehose)
  - [7. Install and Configure Kinesis Agent](#7-install-and-configure-kinesis-agent)
  - [8. Test the Pipeline](#8-test-the-pipeline)
- [Validation Checklist](#validation-checklist)
- [Monitoring & Metrics](#monitoring--metrics)
- [Troubleshooting](#troubleshooting)
- [Cost Breakdown](#cost-breakdown)
- [Lessons Learned](#lessons-learned)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Author](#author)
- [References](#references)

---

## Project Overview

As part of my AWS Solutions Architect training, I built a real-time log streaming pipeline to solve a common enterprise problem: efficiently managing and analyzing log data from EC2-hosted applications.

### The Business Problem

An e-commerce platform generates massive amounts of log data daily. Traditional log management (storing logs locally on EC2 instances) creates several issues:

- Logs are lost when instances terminate
- No centralized storage for analysis
- Difficult to monitor in real-time
- Storage limitations on EC2 volumes

### The Solution

I designed and implemented an end-to-end data streaming pipeline that captures Apache web server logs in real-time and streams them to Amazon S3 for permanent storage and analysis.

### Key Achievements

- ✅ Deployed sample website on EC2 with Apache web server
- ✅ Created Kinesis Data Stream with server-side encryption
- ✅ Configured Kinesis Agent to tail Apache access logs
- ✅ Built Firehose delivery stream to S3
- ✅ Validated end-to-end log streaming within minutes
- ✅ Implemented encryption at rest and in transit

---

## Architecture Diagram 
![architecture-diagram](doc/architecture-diagram.png)



---

## Technologies Used

| Service | Purpose |
|---------|---------|
| **Amazon EC2** | Hosts the sample website and Apache web server |
| **Apache HTTP Server** | Web server generating access logs |
| **Amazon Kinesis Data Streams** | Real-time log ingestion with encryption |
| **Amazon Kinesis Agent** | Tails log files and publishes to Kinesis |
| **Amazon Kinesis Data Firehose** | Delivers streaming data to S3 |
| **Amazon S3** | Durable, scalable log storage with encryption |
| **AWS IAM** | Instance profile for EC2 permissions |
| **Amazon CloudWatch** | Monitoring metrics for Kinesis and Firehose |


---

## Implementation Steps

### 1. EC2 Instance Setup

**Objective:** Launch an EC2 instance that will host the sample website.

| Parameter | Value |
|-----------|-------|
| **Instance Name** | Demo_Instance |
| **AMI** | Amazon Linux 2023 AMI |
| **Instance Type** | t2.micro |
| **Key Pair** | Created for SSH access |
| **Security Group** | SSH (port 22) + HTTP (port 80) |
| **IAM Instance Profile** | EC2_Role_<RANDOM_NUMBER> |

**Steps:**

1. Navigate to EC2 Dashboard → Instances → Launch Instance
2. Enter name: `Demo_Instance`
3. Select Amazon Linux 2023 AMI
4. Choose t2.micro (free tier eligible)
5. Create or select an existing key pair
6. Configure security group with:
   - SSH (22) from anywhere
   - HTTP (80) from anywhere
7. Under Advanced details, select IAM instance profile: `EC2_Role_<RANDOM_NUMBER>`
8. Launch instance

---

### 2. Host Sample Website

**Objective:** Install Apache web server and deploy a sample website.

#### 2.1 SSH into EC2 Instance

```bash
ssh -i your-key.pem ec2-user@<public-ip-address>
```

#### 2.2 Install Apache Web Server
```bash
# Update system packages
sudo dnf update -y

# Install Apache web server
sudo dnf install -y httpd

# Start Apache service
sudo systemctl start httpd

# Enable Apache to start on boot
sudo systemctl enable httpd

# Verify Apache is running
sudo systemctl status httpd
```

#### 2.3 Download Sample Website Template
```bash 
# Navigate to web root directory
cd /var/www/html

# Download sample website template
sudo wget https://www.tooplate.com/zip-templates/2137_barista_cafe.zip

# Extract the template
sudo unzip 2137_barista_cafe.zip

# Move files to root directory
sudo mv 2137_barista_cafe/* .

# Clean up
sudo rm -rf 2137_barista_cafe 2137_barista_cafe.zip

# Set proper permissions
sudo chown -R apache:apache /var/www/html
```