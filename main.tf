provider "aws" {
  region = "us-east-1"
}

# NETWORK

resource "aws_vpc" "tkh_fortress" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TKH-Fortress-VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tkh_fortress.id

  tags = {
    Name = "TKH-Internet-Gateway"
  }
}

resource "aws_subnet" "public_courtyard" {
  vpc_id     = aws_vpc.tkh_fortress.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-Courtyard"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tkh_fortress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_courtyard.id
  route_table_id = aws_route_table.public_route_table.id
}

# VPC FLOW LOGS

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/tkh/capstone/vpc-flow-logs"
  retention_in_days = 7

  # CloudWatch encryption is outside the required scope of
  # this capstone. VPC Flow Logs are enabled for auditing.
  # tfsec:ignore:aws-cloudwatch-log-group-customer-key

  tags = {
    Name = "TKH-Capstone-VPC-Flow-Logs"
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "tkh-capstone-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "tkh-capstone-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  vpc_id               = aws_vpc.tkh_fortress.id
  traffic_type         = "REJECT"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_log_role.arn

  tags = {
    Name = "TKH-VPC-Flow-Log"
  }
}

# FIREWALL

resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and restricted SSH access"
  vpc_id      = aws_vpc.tkh_fortress.id

  # Public HTTP is explicitly required by the assignment
  # tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "Allow HTTP from the public internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH is restricted to one trusted home IP
  ingress {
    description = "Allow SSH only from home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["69.203.193.205/32"]
  }

  # Outbound internet access is required to install httpd
  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  
  egress {
    description = "Allow outbound traffic for package installation"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TKH-Web-Server-SG"
  }
}

# AMAZON LINUX 2023

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# WEB SERVER

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_courtyard.id
  vpc_security_group_ids      = [aws_security_group.web_server_sg.id]
  associate_public_ip_address = true

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt EC2 root storage
  root_block_device {
    encrypted = true
  }

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "TKH-Web-Server"
  }
}