 ## Key Takeaways


### What Went Wrong Initially:
1. Subnets not associated with public route table
2. HTTP rule missing in security group
3. Apache service needed verification after user-data


### Troubleshooting Process Learned:

```text 
1. Start with the load balancer (farthest from instance)
2. Work backwards through each component:
   - DNS resolution ✓
   - Load balancer configuration ✓
   - Target group health ✓
   - Security groups ✓
   - Route tables ✓
   - IGW attachment ✓
   - EC2 instance ✓
   - Apache service ✓
3. Verify each layer before moving deeper
```