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