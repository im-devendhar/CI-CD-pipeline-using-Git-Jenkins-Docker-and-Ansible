
***

# 📘 Ansible POC: Control Server ↔ Private EC2 Webservers

This document explains how we configured a **public control server** to automatically detect and manage **private EC2 instances** using **Ansible Dynamic Inventory (AWS EC2 Plugin)**.

***

##  Architecture Overview

    Control Server (Public Subnet)
         ↓ SSH (private IP)
    Private Webserver 1 (10.0.x.x)
    Private Webserver 2 (10.0.y.y)

*   Control server has public IP → you SSH into it
*   Two webservers are in private subnet → **no public IPs**
*   Only the control server can reach them
*   Ansible Dynamic Inventory automatically discovers them

***

##  Step 1: Setup Repo on Control Server

Clone the GitHub repo and verify folder structure:

    CI-CD-pipeline-using-Git-Jenkins-Docker-and-Ansible/
    ├── Dockerfile
    ├── Jenkinsfile
    ├── README.md
    ├── deploy.yml
    ├── inventory/
    │   └── aws_ec2.yml
    └── src/

***

##  Step 2: Add the PEM Key on Control Server

The PEM file is stored at:

    /home/ubuntu/.ssh/prod.pem

Set correct permissions:

```bash
chmod 600 ~/.ssh/prod.pem
```

***

##  Step 3: Install Required Packages on Control Server

```bash
sudo apt update
sudo apt install python3-boto3 -y
sudo apt install awscli -y
aws configure
```

AWS credentials must have:

    ec2:DescribeInstances

***

##  Step 4: Tag the Private EC2 Servers Correctly

Each private webserver **must** have:

| Key  | Value     |
| ---- | --------- |
| role | webserver |

This is required for Ansible EC2 Plugin filtering.

***

##  Step 5: Create Dynamic Inventory File

`inventory/aws_ec2.yml`

```yaml
plugin: aws_ec2
regions:
  - us-east-1

filters:
  tag:role: webserver

hostnames:
  - private-ip-address

compose:
  ansible_user: "'ubuntu'"
  ansible_ssh_private_key_file: "'/home/ubuntu/.ssh/prod.pem'"
```

This file tells Ansible to automatically:

*   Search AWS for EC2 instances with the tag `role=webserver`
*   Use **private IPs** (not public IPs)
*   Use `ubuntu` user
*   Use the PEM file for SSH authentication

***

##  Step 6: Verify Dynamic Inventory Detection

Run:

```bash
ansible-inventory -i inventory/aws_ec2.yml --graph
```

Expected result:

    @all:
     |--@aws_ec2:
     |   |--10.0.2.234
     |   |--10.0.2.116

This confirms Ansible is discovering both private EC2s.

***

## ✅ Step 7: Test Connectivity (Ping)

```bash
ansible aws_ec2 -i inventory/aws_ec2.yml -m ping
```

Expected:

    10.0.2.234 | SUCCESS => {"ping": "pong"}
    10.0.2.116 | SUCCESS => {"ping": "pong"}

***

