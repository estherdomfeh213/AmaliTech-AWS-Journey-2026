# EC2 Instance Commands

# Switch to root
sudo su

# Update system
yum -y update

# Install Apache
yum install httpd -y

# Start Apache
systemctl start httpd

# Enable on boot
systemctl enable httpd

# Check status
systemctl status httpd

# Create test page
echo "<html><h1>Response coming from server</h1></html>" > /var/www/html/index.html

# Restart Apache
systemctl restart httpd

# View logs
tail -f /var/log/httpd/access_log
tail -f /var/log/httpd/error_log



# Network Troubleshooting Commands

# Check connectivity
curl http://localhost
curl http://<EC2-Public-IP>

# Check network interfaces
ip addr show
netstat -tulpn | grep :80

# Check route table
route -n
ip route show

# Test DNS resolution
nslookup amazon.com
dig google.com


# AWS CLI Commands (for reference)

```bash 
# Describe VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=MyVPC"

# Describe subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx"

# Describe load balancer
aws elbv2 describe-load-balancers --names Myapplication-LB

# Check target group health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
```

