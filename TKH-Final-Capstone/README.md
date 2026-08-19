# Secure Automated Web Architecture

## Description

This project deploys a secure AWS web server infrastructure using Terraform and Infrastructure as Code (IaC). It combines AWS networking and security controls with a GitHub Actions DevSecOps pipeline that uses tfsec to automatically scan the Terraform configuration for security vulnerabilities before deployment.

## Technologies Used

- AWS
- Terraform
- GitHub Actions
- tfsec

## Architecture

The architecture uses a custom AWS VPC (`10.0.0.0/16`) with a public subnet (`10.0.1.0/24`) connected to an Internet Gateway through a dedicated route table. An Amazon Linux 2023 EC2 instance runs Apache HTTP Server and receives a public IP specifically at the instance level rather than automatically exposing every resource launched in the subnet.

The Security Group follows a restricted-access design by allowing HTTP traffic on port 80 for the public web server while limiting SSH traffic on port 22 to a specific trusted home IP address. The EC2 root volume is encrypted, and IMDSv2 is required to strengthen instance metadata security.

VPC Flow Logs were added after the tfsec security scan identified missing network logging. Rejected network traffic is captured and sent to an encrypted CloudWatch Log Group, providing additional visibility for auditing and security monitoring.

The GitHub Actions pipeline automatically runs tfsec whenever code is pushed to the `main` branch. Security findings identified during the initial scan were remediated or documented when access was intentionally required by the architecture, resulting in a successful GREEN security quality gate.