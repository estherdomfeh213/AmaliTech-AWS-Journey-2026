# Cleanup Instructions

#* To avoid charges after completing the challenge:

# 1. Terminate EC2 Instances
aws ec2 terminate-instances --instance-ids i-xxxxx i-yyyyy

# 2. Delete NAT Gateway (waits ~5 minutes)
aws ec2 delete-nat-gateway --nat-gateway-id nat-xxxxx
# Release associated Elastic IP

# 3. Detach and delete Internet Gateway
aws ec2 detach-internet-gateway --internet-gateway-id igw-xxxxx --vpc-id vpc-xxxxx
aws ec2 delete-internet-gateway --internet-gateway-id igw-xxxxx

# 4. Delete subnets
aws ec2 delete-subnet --subnet-id subnet-xxxxx
aws ec2 delete-subnet --subnet-id subnet-yyyyy

# 5. Delete route tables (after disassociating)
aws ec2 delete-route-table --route-table-id rtb-xxxxx

# 6. Delete VPC
aws ec2 delete-vpc --vpc-id vpc-xxxxx