terraform {
  backend "s3" {
    bucket = "devops-demo-state-1"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# Dynamic AMI Lookup (Using the code you provided)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Firewall Rules
resource "aws_security_group" "sg" {
  name = "allow_app_traffic"

  ingress { from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }     # SSH
  ingress { from_port = 5000; to_port = 5000; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] } # Flask
  ingress { from_port = 3000; to_port = 3000; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] } # Grafana
  ingress { from_port = 9090; to_port = 9090; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] } # Prometheus

  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

# The EC2 Instance
resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id # Uses the dynamic ID from the data block
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "my-key" # Ensure this matches your AWS console key name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu
              EOF
}

# Elastic IP Association
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.server.id
  allocation_id = "eipalloc-0faf631d22521d0ab" # Fixed Elastic IP ID
}