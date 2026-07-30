provider "aws" {  
  region = "us-east-1"  
}  
  
resource "aws_security_group" "sabotaged_sg" {  
  name        = "tlab7-exposed-sg"  
  description = "A dangerously exposed security group"  
  
  ingress {  
    from_port   = 22  
    to_port     = 22  
    protocol    = "tcp"  
    cidr_blocks = ["192.168.56.1/32"] 
  }  
}  
