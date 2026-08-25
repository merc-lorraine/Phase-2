# Secure Automated Web Architecture

## Project Overview

This project demonstrates a **secure AWS web architecture** built with Terraform and protected through an automated DevSecOps security pipeline. The project deploys an Apache web server inside a custom VPC while using security controls for network access, encryption, logging, and automated vulnerability scanning.

The goal was to build functional cloud infrastructure while integrating security directly into the deployment process.

---

## Technologies Used

- AWS
- Terraform
- GitHub Actions
- tfsec
- Amazon EC2
- Amazon VPC
- VPC Flow Logs
- Amazon CloudWatch
- AWS KMS
- IAM

---

## Architecture

The environment uses a custom VPC (`10.0.0.0/16`) with a public subnet (`10.0.1.0/24`). A dedicated route table connects the subnet to an Internet Gateway, allowing the EC2 web server to serve public HTTP traffic.

```text
Internet Gateway
       |
       v
VPC (10.0.0.0/16)
       |
       v
Public Subnet (10.0.1.0/24)
       |
       v
Security Group
       |
       v
EC2 Web Server
```

The Security Group allows **HTTP on port 80** for the public website while restricting **SSH on port 22** to a trusted IP address.

The EC2 instance is further hardened with:

- Encrypted root storage
- IMDSv2 enforcement
- Restricted SSH access
- Instance-specific public IP assignment

---

## Security Monitoring

**VPC Flow Logs** capture rejected network traffic and send the logs to Amazon CloudWatch for monitoring and auditing.

The CloudWatch Log Group is protected using **AWS KMS encryption**, providing additional protection for stored security logs.

---

## DevSecOps Pipeline

A GitHub Actions workflow automatically runs **tfsec** whenever code is pushed to the `main` branch.

```text
Terraform Code
      |
      v
GitHub Push
      |
      v
GitHub Actions
      |
      v
tfsec Security Scan
      |
      v
PASS / FAIL
```

The pipeline uses:

```yaml
tfsec_args: --soft-fail=false
```

This causes the security quality gate to **fail when vulnerabilities are detected**.

---

## Security Remediation

The initial tfsec scan identified several security issues that were remediated during the project.

| Finding | Remediation |
|---|---|
| Unencrypted EC2 storage | Enabled root-volume encryption |
| IMDSv2 not enforced | Required metadata tokens |
| Missing Security Group descriptions | Added rule descriptions |
| Missing VPC Flow Logs | Added VPC Flow Logs |
| Unencrypted CloudWatch logs | Added KMS encryption |
| Public IP assigned at subnet level | Assigned public IP only to EC2 |

Required public access, such as HTTP on port 80, was documented as an intentional exception.

After remediation, the **tfsec security pipeline successfully passed GREEN**.

---

## Results

The final project successfully:

- Deployed AWS infrastructure using Terraform
- Hosted a live Apache web server
- Restricted network access using Security Groups
- Encrypted EC2 storage
- Enforced IMDSv2
- Added VPC Flow Logs and CloudWatch monitoring
- Protected logs with KMS encryption
- Integrated tfsec with GitHub Actions
- Achieved a successful GREEN security quality gate

---

## What I Learned

This project demonstrated how **Infrastructure as Code and automated security scanning can work together to identify and remediate cloud security risks before deployment**.

It also reinforced how networking, encryption, logging, IAM, EC2 hardening, and CI/CD security controls contribute to a layered cloud security strategy.

---

## Next Steps

Future improvements could include:

- Replace SSH with AWS Systems Manager Session Manager
- Add HTTPS/TLS
- Add an Application Load Balancer
- Implement AWS WAF
- Expand security monitoring and alerting

---

## Infrastructure Teardown

After the final demonstration, the infrastructure is destroyed to prevent unnecessary AWS charges.
 
```bash
terraform destroy
```

---

## Key Takeaway

> **Security was built into the infrastructure and the deployment pipeline rather than added after deployment.**
