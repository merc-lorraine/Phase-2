# TLAB6: Monitored Fortress

## Overview

Monitored Fortress is a secure AWS environment built with **Terraform** that combines network security, monitoring, and secure EC2 access.

The project uses **VPC Flow Logs and CloudWatch** to monitor network activity while **AWS Systems Manager (SSM)** provides administrative access without exposing SSH to the internet.

## Architecture

The environment includes:

- Custom AWS VPC and subnet
- Internet Gateway and route table
- EC2 instance
- Security Group with no inbound SSH access
- AWS Systems Manager (SSM)
- VPC Flow Logs
- CloudWatch Logs
- IAM roles and policies

## Security Features

### Secure EC2 Access
The EC2 instance is managed through **AWS Systems Manager Session Manager**, eliminating the need to expose port `22` for SSH.

### Network Monitoring
**VPC Flow Logs** send network traffic data to CloudWatch, providing visibility into accepted and rejected connections.

### Infrastructure as Code
The environment is deployed using **Terraform**, making the infrastructure repeatable and easier to manage securely.

## Technologies Used

- Terraform
- AWS VPC
- Amazon EC2
- AWS IAM
- AWS Systems Manager
- VPC Flow Logs
- Amazon CloudWatch

## Deployment

```bash
terraform init
terraform plan
terraform apply
