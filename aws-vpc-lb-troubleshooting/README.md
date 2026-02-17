# Toubleshooting VPC,EC2,and Load Balancer Connectivity 

##  Lab Overview
A comprehensive hands-on lab demonstrating network connectivity troubleshooting between VPC components, EC2 instances, and Application Load Balancers in AWS.

## Architecture Diagram
![vpc-load balancer architecture](architecture/vpc-lb-architecture.png)


## Lab Objectives
- Create a custom VPC with public subnets across two Availability Zones
- Configure Internet Gateway for internet connectivity
- Set up route tables with proper routing rules
- Launch EC2 instance with Apache web server (via user-data)
- Create and configure Application Load Balancer
- Test load balancer connectivity
- Troubleshoot and fix common connectivity issues
- Validate the complete infrastructure


## Infrastructure Components 

### Network Configuration 


|Components |Name|Configuaration |Purpose |
|---|---|---|
|VPC |MyVPC |10.0.0.0/16 |Isolated network environment |
|Subnet 1|MyPublicSubnet1 |10.0.1.0/24 (us-east-1a) |Public-facing resources|
|Subnet 2|MyPublicSubnet2 |10.0.2.0/24 (us-east-1b)  |High availability across AZs|
|Internet Gateway|MyInternetGateway|Attached to MyVPC |Internet connectivity|
|Route Table|PublicRouteTable | 0.0.0.0/0 → IGW |Route internet traffic|

