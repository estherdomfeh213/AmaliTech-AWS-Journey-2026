# NAT Gateway - AWS VPC 

## Challenge Overview

As a Security Engineer at ABC Company, I was tasked with building a secure VPC infrastructure that allows a private EC2 instance to access the internet for updates while remaining inaccessible from the outside world. This challenge tested my understanding of AWS networking, VPC components, and security best practices.

## The Business Requirement

**Company ABC's Infrastructure Need:**

- Public EC2 Instance: Host a web application accessible from the internet
- Private EC2 Instance: Host another application that must remain private
- Security Requirement: Private instance needs internet access for updates (yum updates, package installations) but must NOT be directly accessible from the internet
- My Role: Security Engineer - Design and implement the solution


##  Solution Architecture

![Solution architecture diagram](architecture-diagram/architecture.png)


## My Step-by-Step Implementation

### Phase 1: Building the Network Foundation

#### Task 1: Create the VPC

```bash 
# My VPC Configuration:
VPC Name: MyVPC
CIDR Block: 10.0.0.0/16
Tenancy: Default
Region: us-east-1
```
**Why this CIDR?** The 10.0.0.0/16 range gives me 65,536 IP addresses - plenty for current and future needs.

#### Task 2: Create Subnets (Public & Private)

| Subnet | Name | CIDR | AZ | Auto-assign Public IP	 | Purpose |
|---------| ------------|-------------------|--------|------|------|
|Public |MyPublicSubnet | 10.0.0.0/24| us-east-1a | Enabled
| Private | MyPrivateSubnet |10.0.1.0/24 | us-east-1a | Disabled


**My Design Decision:** I placed both subnets in the same AZ for simplicity, but in production I'd spread them across AZs for high availability.


#### Task 3: Create and Attach Internet Gateway

```bash 
# Create IGW
IGW Name: MyIGW
# Attach to VPC
Attachment: MyVPC
```
**Verification:** Internet Gateway successfully attached to MyVPC


#### Task 4: Configure Public Route Table
```bash 
# Create route table
Route Table Name: MyPublicRT
VPC: MyVPC

# Add route for internet access
Destination: 0.0.0.0/0
Target: MyIGW

# Associate with public subnet
Subnet Associations: MyPublicSubnet
```
**Why this matters:** Without this route, instances in the public subnet can't reach the internet.


### Phase 2: Deploying EC2 Instances

#### Task 5: Launch Public EC2 Instance

```bash 
# Instance Configuration:
Name: MyPublicEC2Server
AMI: Amazon Linux 2023 kernel-6.1
Type: t2.micro
Storage: 8GB gp2 EBS
Network:
  - VPC: MyVPC
  - Subnet: MyPublicSubnet
  - Auto-assign Public IP: Enable
Security Group: MyEC2Server_SG (SSH from Anywhere)
Key Pair: Created new key pair for public instance
```

#### Task 6: Launch Private EC2 Instance

```bash 
# Instance Configuration:
Name: MyPrivateEC2Server
AMI: Amazon Linux 2023 kernel-6.1
Type: t2.micro
Storage: 8GB gp2 EBS
Network:
  - VPC: MyVPC
  - Subnet: MyPrivateSubnet
  - Auto-assign Public IP: Disable (CRITICAL for security)
Security Group: MyEC2Server_SG (same as public)
Key Pair: Created new key pair for private instance
```

**Security Note:** The private instance has NO public IP, this is the first layer of security. It cannot be reached directly from the internet.


### Phase 3: Initial Testing (Before NAT Gateway)

#### Task 7: Test Connectivity - The "Before" State

##### Step 1: SSH into Public EC2 Instance
```bash 
# From my local machine
ssh -i "MyKey.pem" ec2-user@<Public-EC2-Public-IP>

# Output:
[ec2-user@ip-10-0-0-10 ~]$
```
Successfully connected to public instance


##### Step 2: Copy Private Key to Public Instance
```bash 
# On my local machine, copy private key to public instance
scp -i "MyKey.pem" "MyKey.pem" ec2-user@<Public-EC2-IP>:~/

# On public instance, set correct permissions
chmod 400 MyKey.pem
```

##### Step 3: SSH into Private EC2 from Public EC2

```bash 
# From public instance
ssh -i "MyKey.pem" ec2-user@10.0.1.10

# Output:

[ec2-user@ip-10-0-1-10 ~]$
```

Successfully connected to private instance via bastion host pattern

##### Step 4: Test Internet Access on Private Instance

```bash 
# On private instance, try to update packages
sudo yum -y update

# Output:
Loaded plugins: priorities, update-motd, upgrade-helper
Could not retrieve mirrorlist http://amazonlinux-2023-repos-us-east-1.s3.dualstack.us-east-1.amazonaws.com/... error was
14: curl#7 - "Failed to connect to 52.216.134.75: Connection timed out"

# Try to ping google.com
ping google.com

# Output:
ping: google.com: Temporary failure in name resolution

# Try to install httpd
sudo yum install httpd -y

# Output:
Error: Cannot find a valid baseurl for repo: amzn2-core/0/x86_64
```

**EXPECTED FAILURE**  Private instance has NO internet access! This is correct behavior.

![Fail Internet Acces](screenshots/07-before-nat-fail.png.png)


### Phase 4: Implementing the Solution - NAT Gateway

#### Task 8: Create NAT Gateway in Public Subnet
```bash 
# Create NAT Gateway
Name: MyNATGateway
Subnet: MyPublicSubnet (MUST be in public subnet)
Connectivity Type: Public
Elastic IP: Allocate Elastic IP
```
**Why Public Subnet?** NAT Gateway needs internet access itself to forward traffic from private instances.

**Cost Consideration:** NAT Gateway costs ~$0.045/hour + data processing fees. In production, consider NAT Instance for lower costs.

#### Task 9: Update Main Route Table for Private Subnet
```bash 
# Find the Main Route Table (NOT MyPublicRT)
VPC → Route Tables → Main Route Table (different from MyPublicRT)

# Add route for private subnet internet access
Destination: 0.0.0.0/0
Target: MyNATGateway

# Verify association: This route table should be associated with MyPrivateSubnet
```
**Critical Insight:** AWS creates a "Main" route table automatically. I needed to modify THIS one, not my custom public route table.


### Phase 5: Testing - The "After" State

#### Task 10: Re-test Internet Access on Private Instance

##### Step 1: Reconnect to Private Instance (via bastion)

```bash 
# From my local → Public EC2
ssh -i "MyKey.pem" ec2-user@<Public-EC2-IP>

# From Public EC2 → Private EC2
ssh -i "MyKey.pem" ec2-user@10.0.1.10
```

##### Step 2: Test Package Updates

```bash 
# On private instance, try yum update AGAIN
sudo yum -y update

# Output (THIS TIME IT WORKS!):
Loaded plugins: priorities, update-motd, upgrade-helper

Complete!
```
**SUCCESS!** Private instance can now access internet for updates!

##### Step 3: Test Package Installation
```bash 
# Install httpd on private instance
sudo yum install httpd -y

# Output:
Complete!
```
**SUCCESS!** Private instance can install packages from internet repositories!

![Private Internet Access](screenshots/09-after-nat-success.png)

##### Step 4: Verify Private Instance Still Has No Public IP

```bash 
# Check if private instance has public IP
ip addr show
curl ifconfig.me

# Output:
curl: (7) Failed to connect to ifconfig.me port 80: Connection timed out
```
**SECURITY VERIFIED!** Private instance still has NO direct internet access - all traffic goes through NAT


### Phase 6: Understanding the Traffic Flow

```text
OUTBOUND TRAFFIC (Private Instance → Internet):
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Private    │────▶│    NAT      │────▶│  Internet   │────▶│  yum repo   │
│  EC2        │     │  Gateway    │     │  Gateway    │     │  server     │
│  10.0.1.10  │     │ 10.0.0.50   │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                    │
      │ Private Subnet    │ Public Subnet     │ Internet           │ Response
      │ Route Table:      │ Route Table:      │                    │
      │ 0.0.0.0/0 → NAT   │ 0.0.0.0/0 → IGW   │                    │
      │                   │                   │                    │
      └───────────────────┴───────────────────┴────────────────────┘

INBOUND TRAFFIC (Internet → Private Instance):
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Hacker     │────▶│  Internet   │────▶│    NAT      │
│  attempts   │     │  Gateway    │     │  Gateway    │
│  to connect │     │             │     │             │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                          DROPPED
                                      NAT Gateway does NOT
                                      forward unsolicited
                                      inbound traffic
```


### Deep Dive: How NAT Gateway Works


```text
Private Instance (10.0.1.10) wants to reach yum repo (54.123.45.67):

1. Packet leaves private instance:
   Source IP: 10.0.1.10
   Dest IP: 54.123.45.67
   Source Port: 34567

2. NAT Gateway receives packet:
   Changes Source IP to: 54.198.123.45 (NAT's public IP)
   Changes Source Port to: 1024 (tracks mapping)
   Remembers: 10.0.1.10:34567 ↔ 54.198.123.45:1024

3. Response from yum repo (54.123.45.67):
   Dest IP: 54.198.123.45
   Dest Port: 1024

4. NAT Gateway looks up mapping:
   Sees 1024 maps to 10.0.1.10:34567
   Changes Dest IP back to 10.0.1.10
   Forwards to private instance

5. If a packet arrives for 54.198.123.45:1024 
   without an existing mapping → DROPPED
   This is why unsolicited inbound fails!
```

#### Security Benefits
- Private instances have no public IP
- NAT gateway only forwards responses to established connections
- No inbound holes in security groups needed
- All private instances share one public IP (cost-effective)
- Can't port scan or directly attack private instances

### Skills Demonstrated

- AWS Networking: VPC, Subnets, Route Tables, IGW, NAT Gateway
- EC2 Management: Instance launch, Security Groups, Key Pairs
- Linux Administration: SSH, Package Management, System Updates
- Security Architecture: Bastion Host Pattern, Network Segmentation
- Troubleshooting: Systematic problem-solving, Connectivity Testing
- Infrastructure Design: High Availability, Cost Optimization
- Documentation: Clear technical writing, Architecture Diagrams

### Real-World Application
This architecture is used daily by companies like:

- Netflix: Private streaming backends
- Airbnb: Secure internal services
- Financial Institutions: Isolated transaction processing
- Healthcare: HIPAA-compliant data storage

The pattern I implemented is EXACTLY what runs production systems at scale!




## Project Structure

```text
nat-gateway-aws-challenge/
├── README.md                    # This documentation
├── architecture-diagrams/       # Visual architecture
│   ├── architecture-diagram-png
│   
├── scripts/                     # Automation scripts
│   ├── create-infrastructure.sh
│   ├── test-connectivity.sh
│   └── cleanup-resources.sh
├── user-data/                   # EC2 bootstrap scripts
│   ├── public-instance.sh
│   └── private-instance.sh
├── screenshots/                  # Proof of completion
│   ├── 01-vpc-created.png
│   ├── 02-subnets.png
│   ├── 03-igw-attachment.png
│   ├── 04-route-tables.png
│   ├── 05-public-ec2.png
│   ├── 06-private-ec2.png
│   ├── 07-before-nat-fail.png
│   ├── 08-nat-gateway.png
│   ├── 09-after-nat-success.png
│   └── 10-validation.png
└── docs/                        # Additional documentation
    ├── troubleshooting-guide.md
    ├── cost-analysis.md
    └── best-practices.md
```

