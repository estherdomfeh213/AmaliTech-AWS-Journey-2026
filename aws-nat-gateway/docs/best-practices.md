# What I Learned: Key Concepts
1. VPC Components
- VPC: Virtual private cloud - my isolated network
- Subnets: Segments within VPC for organization
- Internet Gateway: Door to the internet
- Route Tables: Traffic direction signs
- NAT Gateway: One-way door for private instances

2. Security Patterns
Bastion Host: Jump box to access private resources
- NAT Gateway: Outbound-only internet access
- No Public IPs: Private instances stay invisible
- Security Groups: Instance-level firewalls

3. AWS Best Practices
Always design for least privilege
- Separate public and private tiers
-Use NAT for private instance updates
- Document all configurations
- Test thoroughly at each step


