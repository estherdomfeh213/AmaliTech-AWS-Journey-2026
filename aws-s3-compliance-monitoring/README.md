# AWS S3 Compliance Monitoring & Auto-Remediation System

## 📌 Project Overview

Designed and implemented an event-driven compliance monitoring and auto-remediation system for Amazon S3 using AWS native services.

This solution continuously evaluates S3 bucket configurations against security best practices and automatically detects, alerts, and remediates non-compliant resources.

The architecture demonstrates a production-style approach to:

- Cloud security and governance  
- Real-time monitoring and alerting  
- Event-driven automation  
- Risk mitigation for public data exposure  

---

## 🏗 Architecture Overview

### Core Services

- AWS Config – Continuous resource configuration tracking and compliance evaluation  
- Amazon S3 – Storage service monitored for security compliance  
- Amazon EventBridge – Event routing for real-time response  
- AWS Lambda – Serverless compute for automated remediation  
- Amazon SNS – Notification service for alerting  

---

## Architecture Flow

S3 Bucket Configuration Change  
→ AWS Config Rule Evaluation  
→ Non-Compliant Resource Detected  
→ EventBridge Rule Triggered  
→ Lambda Function Executes  
→ SNS Notification Sent  

---

## Compliance Rules Implemented

The system enforces the following AWS managed rules:

- `s3-bucket-public-read-prohibited`  
- `s3-bucket-public-write-prohibited`  

These rules ensure that S3 buckets are not publicly accessible, reducing the risk of data exposure.

---

## Event-Driven Detection

An EventBridge rule captures non-compliant evaluation results from AWS Config:

```json
{
  "source": ["aws.config"],
  "detail": {
    "requestParameters": {
      "evaluations": {
        "complianceType": ["NON_COMPLIANT"]
      }
    }
  }
}