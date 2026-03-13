**💰 Cost Analysis/**


| Resource | Configuration | Monthly Cost 
|------|----------|------|--------|---------|
| Aurora Primary | db.t3.medium |  ~$70
| Aurora Replica|  db.t3.medium | ~$70 
| EC2 Bastion | t2.micro |  ~$8
| TOTAL |   | ~$150/month

**Cost Optimization Tips**
- Use Aurora Serverless for intermittent workloads
- Stop instances during non-business hours
- Use Reserved Instances for 1-3 year commitments