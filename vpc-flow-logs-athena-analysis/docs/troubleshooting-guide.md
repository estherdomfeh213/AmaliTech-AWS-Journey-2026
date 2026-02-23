# 🛠️ Troubleshooting Guide

### Issue 1: No Logs Appearing in S3

**Symptoms:**
- S3 bucket empty after 10+ minutes
- No folder structure created

**Checklist:**
```bash 
✓ Is bucket policy correct? (delivery.logs.amazonaws.com permission)
✓ Is bucket ARN correctly entered in flow log?
✓ Is flow log status "Active"?
✓ Has 5-10 minutes passed since creation?
```
**Fix:** Re-create flow log with correct bucket ARN

### Issue 2: Athena Query Returns Zero Rows
 
**Symptoms:**

- Query runs but returns 0
- Table exists but no data

**Checklist:**
```bash 
✓ Is Glue table pointing to correct S3 path?
✓ Are logs in the expected partition structure?
✓ Does schema match actual data format?
```
**Fix:** Verify S3 path includes AWSLogs/<account-id>/vpcflowlogs/

### Issue 3: Schema Mismatch Errors

**Symptoms:**
- Athena queries fail with "HIVE_BAD_DATA"
- Field type errors

**Fix:** Ensure JSON schema matches VPC Flow Logs format (default format)

### Issue 4: Permission Denied for Athena Queries
**Symptoms:**
- "Access Denied" when running queries
- Cannot write query results

**Fix:**
```bash
# Ensure IAM permissions include:
- s3:GetObject on the log bucket
- s3:PutObject on the query results location
- athena:StartQueryExecution
- glue:GetTable
```