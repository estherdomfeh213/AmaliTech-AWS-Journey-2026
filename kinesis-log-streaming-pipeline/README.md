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