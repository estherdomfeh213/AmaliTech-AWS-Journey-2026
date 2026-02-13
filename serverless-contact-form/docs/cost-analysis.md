# Cost Analysis – Serverless Contact Form

This document provides a cost breakdown of the **Serverless Contact Form** project from a **Solutions Architect perspective**, focusing on efficiency, scalability, and cost optimization.

---

## Cost Design Goals

- Keep operational costs **near zero** for low traffic
- Avoid idle compute resources
- Use managed, serverless AWS services
- Scale automatically without manual intervention

---

## Service-by-Service Cost Breakdown

###  AWS Lambda

**Usage:**
- Handles HTTP requests from API Gateway
- Processes form data and sends email via SES

**Pricing model:**
- 1 million free requests/month
- 400,000 GB-seconds/month (free tier)
- $0.20 per additional million requests

**Assumptions:**
- 128 MB memory
- ~1 second execution time
- 500 requests/month

**Calculation:**
- 0.125 GB-seconds per request
- 500 × 0.125 = 62.5 GB-seconds/month

**Cost:** $0 (within free tier)

---

### Amazon API Gateway (REST API)

**Usage:**
- Public HTTPS endpoint for contact form
- Handles CORS and request routing

**Pricing model:**
- 1 million free requests/month
- $3.50 per million requests thereafter

**Assumptions:**
- 500 requests/month

**Cost:** $0 (within free tier)

---

### Amazon Simple Email Service (SES)

**Usage:**
- Sends transactional emails from contact form

**Pricing model:**
- $0.10 per 1,000 emails sent
- No minimum monthly charge

**Assumptions:**
- 500 emails/month

**Calculation:**
- 500 ÷ 1000 × $0.10 = **$0.05**

**Cost:** ~$0.05/month

---

### Data Transfer

- Inbound data: Free
- Outbound data: First 1 GB/month free

Given the small payload size (JSON + email metadata):

**Cost:** $0

---

### CloudWatch Logs

- Lambda logs stored for debugging
- Text-based logs only

Estimated usage well below 1 GB/month.

**Cost:** ~$0

---

## Monthly Cost Summary

| Service        | Estimated Monthly Cost |
|----------------|------------------------|
| AWS Lambda     | $0.00                  |
| API Gateway    | $0.00                  |
| Amazon SES     | ~$0.05                 |
| Data Transfer  | $0.00                  |
| CloudWatch     | ~$0.00                 |
| **Total**      | **~$0.05/month**       |

---

## Architectural Cost Insights

- **No EC2 instances** → no idle compute cost
- **No databases required** → no storage overhead
- **Pay-per-use model** → cost scales with demand
- **Free tiers leveraged intelligently**

This project demonstrates how **serverless architectures enable production-ready solutions at extremely low cost**, making them ideal for small businesses, portfolios, and early-stage startups.

---

## Cost Optimization Opportunities

- Switch to **HTTP API Gateway** instead of REST API for even lower cost
- Move SES out of sandbox to allow higher throughput
- Add usage-based throttling to prevent abuse
- Use S3 static hosting for frontend (no server cost)

---

## Key Takeaway

> This project showcases the ability to design **cost-efficient cloud-native systems**, a critical skill for cloud engineers and solutions architects.