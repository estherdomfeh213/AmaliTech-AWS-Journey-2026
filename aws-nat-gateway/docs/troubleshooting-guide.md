# Troubleshooting Checklist

**If Private Instance Still Can't Access Internet:**

1. Is NAT Gateway in public subnet?
- Check subnet of NAT Gateway
- Public subnet must have route to IGW

2. Is Main Route Table updated?
- Private subnet uses MAIN route table (usually)
- Check associations: Private subnet → MAIN route table
- MAIN route table has 0.0.0.0/0 → NAT Gateway

3. Is NAT Gateway available?
- Status should be "Available" (takes 2-3 minutes)
- Check if Elastic IP is allocated

4. Security Group blocking outbound?
- Default security group allows all outbound
- Check if you modified outbound rules

5. Network ACLs blocking?
- Default NACLs allow all inbound/outbound
- Check if you created custom NACLs

6. Is instance in correct subnet?
- Verify private instance is in 10.0.1.0/24
- Verify public instance is in 10.0.0.0/24