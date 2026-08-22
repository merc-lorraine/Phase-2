# TLAB5: Budgeted Identity

## Overview

Budgeted Identity is an AWS security lab built with **Terraform** that combines identity and access management, secure cloud storage, and cost monitoring.

The project uses **IAM roles** to provide an EC2 instance with controlled access to a private S3 bucket while **AWS Budgets** monitors cloud spending.

## Architecture

The environment includes:

- Private Amazon S3 bucket
- IAM role and policies
- EC2 instance with an IAM instance profile
- AWS Budget with a $10 monthly limit
- Budget alert at 80% usage
- Terraform-managed infrastructure

## Security Features

### IAM-Based Access

The EC2 instance uses an **IAM role** instead of hard-coded AWS credentials, allowing AWS permissions to be securely assigned to the instance.

### Secure S3 Storage

The S3 bucket is configured as a private resource, helping prevent unauthorized public access to stored data.

### Cost Monitoring

An **AWS Budget** tracks cloud spending and provides an alert when usage reaches 80% of the configured $10 budget.

## Technologies Used

- Terraform
- AWS IAM
- Amazon EC2
- Amazon S3
- AWS Budgets

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Key Takeaway

This project demonstrates how **identity controls, private cloud storage, Infrastructure as Code, and cost monitoring** can work together to create a more secure and accountable AWS environment.
