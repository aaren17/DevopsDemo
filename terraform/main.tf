terraform {
  backend "s3" {
    bucket = "devops-demo-state-1" # <--- REPLACE THIS WITH YOUR BUCKET NAME
    key    = "terraform.tfstate"          # Keep this exactly as is
    region = "ap-southeast-1"                  # Keep this as is (unless you used a different region)
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# 1. THE FIREWALL (Open Port 5000)
resource "aws_security_group" "sg" {
  name = "allow_flask"
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. THE SERVER (Ubuntu + Docker Script)
resource "aws_instance" "server" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo docker run -d -p 5000:5000 aaren17/devops-demo:latest
              EOF
}