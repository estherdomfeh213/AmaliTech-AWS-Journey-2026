# AWS WordPress Deployment: EC2 LAMP Stack with phpMyAdmin

## Objective
The goal of this project was to deploy a fully functional WordPress website on AWS EC2:

**Technical Requirements:**
- Amazon Linux 2023 AMI with t2.micro instance
- Apache HTTP Server with PHP support
- MariaDB database with WordPress database
- phpMyAdmin for database management
- Proper folder permissions and Apache configuration

**Validation Criteria:**
- WordPress accessible at /mywordpresswebssite
- phpMyAdmin accessible at /phpMyAdmin
- Database user wpuser with proper privileges
- Apache AllowOverride All configured
- Services enabled on system boot
- WordPress installed with user "John Doe"

## Architecdture Diagram 
![Architecture Diagram](architecture/aws-architecture-diagram.png)

## Implementation Steps
### Phase 1: AWS Infrastructure Setup

#### Step 1: Launch EC2 Instance
- AMI: Amazon Linux 2023
- Instance Type: t2.micro
- Region: us-east-1 (N. Virginia)
- Security Group Rules:
    - SSH (Port 22) - For terminal access
    - HTTP (Port 80) - For web traffic
    - HTTPS (Port 443) - For secure connections

#### Step 2: Connect via SSH
```bash
ssh -i your-key.pem ec2-user@<PUBLIC-IP>

```

**Verification:** SSH connection established

### Phase 2: Web Stack Installation

#### Step 3: System Update & Apache Installation
```bash
sudo dnf update -y
sudo dnf install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

**Output Verification:**
```bash
sudo systemctl is-active httpd  # Should return: active
curl http://localhost           # Should show Apache test page 
```

#### Step 4: PHP Installation
```bash
sudo dnf install php php-mysqlnd php-fpm php-json \
                 php-gd php-mbstring php-xml \
                 php-opcache php-curl -y
sudo systemctl restart httpd
```

**Verify PHP:** 
```bash
php -v   #PHP 8....
```

#### Step 5: MariaDB Installation & Security
```bash
sudo dnf install mariadb105-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure the installation
sudo mysql_secure_installation
```
Recommended answers:
Set root password → Y
Remove anonymous users → Y
Disallow root login remotely → Y
Remove test DB → Y
Reload privileges → Y

### Phase 3: Permissions & Directory Setup

#### Step 6: Critical Permission Configuration
```bash 
# Set ownership to Apache user
sudo chown -R apache:apache /var/www

# Set group write permissions with setgid
sudo chmod -R 2775 /var/www

# Apply directory permissions
find /var/www -type d -exec sudo chmod 2775 {} \;

# Apply file permissions
find /var/www -type f -exec sudo chmod 0664 {} \;

# Verify permissions
ls -ld /var/www
# Output: drwxrwsr-x 3 apache apache 4096 Feb  4 10:30 /var/www
```

### Phase 4: phpMyAdmin Installation

### Step 7: Manual phpMyAdmin Setup
Note: Amazon Linux 2023 does not provide phpMyAdmin via dnf, so manual install was required:

```bash
# Download latest phpMyAdmin
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz

# Extract archive
sudo tar -xvf phpMyAdmin-latest-all-languages.tar.gz

# Rename directory
sudo mv phpMyAdmin-*-all-languages phpMyAdmin

# Set permissions
sudo chown -R apache:apache /var/www/html/phpMyAdmin
sudo chmod -R 755 /var/www/html/phpMyAdmin

# Create temporary directory
sudo mkdir -p /var/www/html/phpMyAdmin/tmp
sudo chmod 777 /var/www/html/phpMyAdmin/tmp
```

### Step 8: phpMyAdmin Configuration
```bash
# Copy configuration template
sudo cp /var/www/html/phpMyAdmin/config.sample.inc.php \
        /var/www/html/phpMyAdmin/config.inc.php

# Edit configuration
sudo nano /var/www/html/phpMyAdmin/config.inc.php
```

```bash
Blowfish secret set in config.inc.php:
$cfg['blowfish_secret'] = 'StrongRandomSecret123!';
```

**Apache restarted:**
```bash
sudo systemctl restart httpd
```

**Verified phpMyAdmin at:** 
```bash
 http://<PUBLIC-IP>/phpMyAdmin   # The EC2 instance Public IP address
``` 

### Phase 5: Database Configuration

#### Step 9: Create WordPress Database 

```sql
-- Connect to MariaDB
sudo mysql -u root -p

-- Execute SQL commands
CREATE DATABASE wordpressdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON wordpressdb.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```
**Privilege Verification:**
```sql
SHOW GRANTS FOR 'wpuser'@'localhost';
-- Output: GRANT ALL PRIVILEGES ON `wordpressdb`.* TO 'wpuser'@'localhost'
```

