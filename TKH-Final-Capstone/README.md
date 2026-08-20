# Secure Automated Web Architecture

> **A DevSecOps capstone project demonstrating secure AWS infrastructure, Infrastructure as Code, automated security scanning, and cloud security hardening.**

---

## Project Overview

This project demonstrates a **secure, automated AWS web architecture** built with **Terraform** and validated through a **DevSecOps security pipeline**.

The environment deploys a public Apache web server inside a custom AWS VPC while implementing security controls for **network access, EC2 hardening, encryption, logging, and automated vulnerability scanning**.

The goal was not only to make the infrastructure functional, but to integrate security directly into the deployment process so vulnerabilities could be **identified and remediated before insecure infrastructure passed the security quality gate**.

---

## Problem Statement

Cloud infrastructure can be deployed quickly, but insecure defaults and overly permissive configurations can introduce unnecessary security risks.

This project addresses that problem by combining **Infrastructure as Code (IaC)** with **automated static security analysis**, allowing vulnerabilities in Terraform configurations to be detected during development rather than after deployment.

---

## Technologies Used

| Technology | Purpose |
|---|---|
| **AWS** | Cloud infrastructure platform |
| **Terraform** | Infrastructure as Code |
| **GitHub Actions** | CI/CD security automation |
| **tfsec** | Terraform static security scanning |
| **Amazon EC2** | Hosts the Apache web server |
| **Amazon VPC** | Provides network isolation |
| **Security Groups** | Controls inbound and outbound traffic |
| **VPC Flow Logs** | Captures network traffic metadata |
| **Amazon CloudWatch** | Stores VPC Flow Log data |
| **AWS KMS** | Encrypts CloudWatch logs |
| **AWS IAM** | Controls permissions for logging services |
| **Apache HTTP Server** | Provides the live web service |

---

## Architecture

The architecture uses a custom AWS VPC:

```text
VPC: 10.0.0.0/16
        |
        |-- Internet Gateway
        |
        v
Public Subnet: 10.0.1.0/24
        |
        |-- Dedicated Route Table
        |       `-- 0.0.0.0/0 -> Internet Gateway
        |
        v
Security Group
        |
        |-- HTTP 80 -> Public Internet
        `-- SSH 22  -> Trusted IP Only
        |
        v
Amazon Linux 2023 EC2
        |
        |-- Apache HTTP Server
        |-- Encrypted Root Volume
        `-- IMDSv2 Required

VPC
 |
 `-- VPC Flow Logs
          |
          v
      CloudWatch
          |
          v
      KMS Encryption
```

The public subnet is connected to an **Internet Gateway** through a dedicated route table, allowing the EC2 web server to serve HTTP traffic.

Rather than automatically assigning public IP addresses to every resource launched in the subnet, the public IP is assigned specifically to the web server instance.

---

## Security Controls

### Security Group

The EC2 Security Group follows a restricted-access design.

**Inbound traffic:**

- **HTTP — Port 80:** Allowed from `0.0.0.0/0` so the public website is accessible.
- **SSH — Port 22:** Restricted to a specific trusted IP address.

This prevents SSH administration from being exposed to the entire internet.

### EC2 Hardening

The EC2 instance includes additional security controls:

- **Encrypted root block device**
- **IMDSv2 required**
- **Amazon Linux 2023**
- **Restricted Security Group**
- **Public IP assigned only to the required instance**

IMDSv2 requires session tokens when accessing the EC2 Instance Metadata Service, providing additional protection against unauthorized metadata access.

---

## VPC Flow Logs

One of the most important security improvements came directly from the automated security scan.

**tfsec identified that VPC Flow Logs were missing from the original architecture.**

VPC Flow Logs were therefore added to capture:

```text
REJECT traffic
```

The logging architecture became:

```text
VPC
 |
 v
VPC Flow Logs
 |
 v
CloudWatch Log Group
 |
 v
AWS KMS Encryption
```

This provides additional network visibility that can support:

- Security monitoring
- Incident investigation
- Network troubleshooting
- Auditing
- Detection of rejected connection attempts

The CloudWatch Log Group is also protected using a **customer-managed AWS KMS key**.

---

## DevSecOps Security Pipeline

Security scanning is integrated directly into the development workflow using **GitHub Actions and tfsec**.

The workflow automatically triggers whenever code is pushed to the `main` branch.

### Pipeline Process

```text
Terraform Code
      |
      v
Push to GitHub
      |
      v
GitHub Actions
      |
      v
tfsec Security Scan
      |
      |-- Vulnerability Found -> BUILD FAILS
      |
      `-- Security Checks Pass -> GREEN
```

The pipeline uses:

```yaml
tfsec_args: --soft-fail=false
```

This means security findings can **physically break the build** rather than being silently ignored.

---

## Security Findings and Remediation

The initial tfsec scans identified multiple security concerns.

| Finding | Remediation |
|---|---|
| Unencrypted EC2 root volume | Enabled root-volume encryption |
| IMDSv2 not enforced | Required metadata service tokens |
| Missing Security Group descriptions | Added descriptions to firewall rules |
| Public IP assignment at subnet level | Assigned public IP only to the EC2 instance |
| Missing VPC Flow Logs | Added VPC Flow Logs |
| Unencrypted CloudWatch logs | Added AWS KMS encryption |
| Public HTTP access | Documented as required for the public web server |
| Public outbound access | Documented as required for Apache installation |
| VPC Flow Log IAM wildcard | Documented the narrowly scoped required exception |

After the security findings were remediated, the **GitHub Actions Terraform SAST Scanner successfully passed**.

### Final Pipeline Status

```text
Terraform SAST Scanner

Status: SUCCESS
```

---

## Methodology

1. **Designed** the AWS network architecture.
2. **Built** the infrastructure using Terraform.
3. **Validated** the Terraform configuration.
4. **Deployed** the infrastructure to AWS.
5. **Verified** that the Apache web server was accessible through the EC2 public IP.
6. **Integrated tfsec** into a GitHub Actions security pipeline.
7. **Reviewed** the vulnerabilities detected by tfsec.
8. **Remediated** the identified security issues.
9. **Added VPC Flow Logs** after tfsec identified missing network logging.
10. **Re-ran the pipeline** until the Terraform SAST Scanner passed.
11. **Destroyed the infrastructure** after testing to prevent unnecessary AWS charges.

### Terraform Validation

```bash
terraform fmt
terraform validate
terraform plan
```

### Deployment

```bash
terraform apply
```

---

## Project Results

The final project successfully achieved:

- Custom AWS VPC
- Public subnet
- Internet Gateway
- Dedicated route table
- Restricted Security Group
- Amazon Linux 2023 EC2 instance
- Automated Apache installation
- Live public web server
- Encrypted EC2 root volume
- IMDSv2 enforcement
- VPC Flow Logs
- CloudWatch logging
- AWS KMS encryption
- GitHub Actions CI/CD workflow
- Automated tfsec security scanning
- Successful **GREEN security quality gate**

---

## What I Learned

This project reinforced that **secure cloud engineering is more than simply getting infrastructure to deploy**.

Automated security scanning identified risks that could easily have been missed during manual review. By combining Terraform with tfsec and GitHub Actions, security became part of the infrastructure development lifecycle rather than something performed only after deployment.

The project also demonstrated how **networking, IAM, encryption, logging, EC2 hardening, and CI/CD security controls work together to create a layered cloud security strategy**.

---

## Next Steps

Future improvements could include:

- Replace direct SSH access with **AWS Systems Manager Session Manager**
- Place the application behind an **Application Load Balancer**
- Enable **HTTPS/TLS**
- Add **AWS WAF** for web-layer protection
- Move application resources into a **private subnet**
- Add centralized security alerting
- Expand Infrastructure as Code security scanning
- Create automated monitoring for suspicious VPC Flow Log activity

---

## Infrastructure Teardown

After testing and demonstrating the project, the AWS resources are destroyed to prevent unnecessary cloud charges.

```bash
terraform destroy
```

The AWS Console is then checked to verify that the **EC2 instance and custom VPC have been successfully removed**.

---

## Key Takeaway

> **Security was not added after deployment — it was built into the infrastructure, validated through automated security scanning, and improved based on the vulnerabilities the pipeline identified.**