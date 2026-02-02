
---

# Troubleshooting Guide – Jenkins + Docker + Ansible (Dynamic Inventory)

---

##  Architecture Overview

```
GitHub
  ↓
Jenkins (CI)
  - Build Docker image
  - Push image to Docker Hub
  ↓
Ansible (CD)
  - Dynamic inventory (AWS EC2)
  - Pull image from Docker Hub
  - Run container on target servers
```

---

##  Issue 1: SSH Permission Denied (`jenkins@IP`)

### Error Observed

```
Permission denied (publickey).
jenkins@10.0.x.x
```

### Root Cause

* EC2 instances were **Ubuntu AMI**
* Ansible defaulted to the **Jenkins OS user (`jenkins`)**
* Ubuntu EC2 allows SSH only via `ubuntu` user

### Fix

Created an `ansible.cfg` file in the **project root** to explicitly define SSH settings.

### `ansible.cfg`

```ini
[defaults]
inventory = inventory/aws_ec2.yml
remote_user = ubuntu
private_key_file = /var/lib/jenkins/.ssh/prod.pem
host_key_checking = False
interpreter_python = auto_silent
```

Result: Ansible started connecting as `ubuntu@IP`

---

## Issue 2: SSH Key Not Found

### Error Observed

```
no such identity: /var/lib/jenkins/.ssh/prod.pem
```

### Root Cause

* SSH private key was **not present** in Jenkins user’s home directory

### Fix

Copied the key and fixed permissions:

```bash
sudo mkdir -p /var/lib/jenkins/.ssh
sudo cp /home/ubuntu/.ssh/prod.pem /var/lib/jenkins/.ssh/
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/prod.pem
sudo chmod 400 /var/lib/jenkins/.ssh/prod.pem
```

Manual verification:

```bash
ssh -i /var/lib/jenkins/.ssh/prod.pem ubuntu@<EC2-IP>
```

Result: SSH connectivity fixed

---

##  Issue 3: Docker API Connection Error

### Error Observed

```
Error while fetching server API version
FileNotFoundError: No such file or directory
```

### Root Cause

* Docker was **not installed or running** on target EC2 servers
* Ansible Docker modules require Docker daemon on target machines

### Fix

Added Docker installation and service startup tasks to `deploy.yml`.

```yaml
- name: Install Docker and dependencies
  apt:
    name:
      - docker.io
      - python3-docker
    state: present
    update_cache: yes

- name: Ensure Docker service is running
  service:
    name: docker
    state: started
    enabled: yes
```

Result: Docker became accessible to Ansible

---

##  Issue 4: Docker Image Not Found on Target Servers

### Error Observed

```
Cannot find the image myapp:v1 locally
```

### Root Cause

* Docker image was built **only on Jenkins**
* Docker images are **local to each machine**
* Target servers did not have the image

### Key Learning

> Docker images must be distributed using a **container registry** (Docker Hub / ECR).

---



---

---

##  Interview / Documentation Summary

> The CI/CD deployment issues were resolved by correctly configuring SSH access for Ubuntu EC2 instances, installing Docker on target servers, and distributing Docker images via Docker Hub instead of relying on local images. This ensured a scalable and production-ready Jenkins–Ansible deployment pipeline.

---
