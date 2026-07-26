provider "aws" {
  region = "us-east-1"
}

# ====================================================================
# TITAN FINTECH: THE MONITORED FORTRESS
# Build your VPC, Subnets, Flow Logs, Security Group, and EC2 instance below.
# 
# Hint: When your EC2 instance needs an IAM profile, use:
# iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
# 
# Hint: When your Flow Log needs an IAM role, use:
# iam_role_arn = aws_iam_role.flow_log_role.arn
# ====================================================================

# The Main VPC
resource "aws_vpc" "Titan_FinTech_Fortress" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Titan_FinTech_Fortress-VPC"
  }
}

# The Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.Titan_FinTech_Fortress.id
}

# The Public Subnet
resource "aws_subnet" "public_courtyard" {
  vpc_id     = aws_vpc.Titan_FinTech_Fortress.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-Courtyard"
  }
}

# The Route Table
resource "aws_route_table" "the_perimeter" {
  vpc_id = aws_vpc.Titan_FinTech_Fortress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Public Subnet being associated with the Internet Route Table.
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_courtyard.id
  route_table_id = aws_route_table.the_perimeter.id
}

# Flow Logs

resource "aws_cloudwatch_log_group" "titan_prod_vpc_logs" {
  name              = "/tkh/titan-prod-vpc-logs"
  retention_in_days = 1
}

resource "aws_flow_log" "titan_prod_vpc_logs" {
  vpc_id = aws_vpc.Titan_FinTech_Fortress.id

  traffic_type = "ALL"

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.titan_prod_vpc_logs.arn

  iam_role_arn = aws_iam_role.flow_log_role.arn
}

# Securtiy Group
resource "aws_security_group" "zero_trust_sg" {
  name        = "TKH-Zero-Trust-SG"
  description = "Zero Trust"

  vpc_id = aws_vpc.Titan_FinTech_Fortress.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instance

resource "aws_instance" "zero_trust_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_courtyard.id

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  vpc_security_group_ids = [
    aws_security_group.zero_trust_sg.id
  ]

  tags = {
    Name = "TKH-Zero-Trust-Node"
  }
}
