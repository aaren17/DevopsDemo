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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu Creators)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
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

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
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
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              
              # 1. WAIT for the system to finish auto-updates (The Fix)
              echo "Waiting for apt lock..."
              while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
                 sleep 5
              done
              echo "Apt lock released."

              # 2. Install Docker
              sudo apt-get update
              sudo apt-get install -y docker.io
              
              # 3. Start Docker and Wait
              sudo systemctl start docker
              sudo systemctl enable docker
              sleep 30  # Wait for Docker Daemon to wake up
              
              # 4. Run Containers
              sudo docker run -d -p 5000:5000 aaren17/devops-demo:latest
              sudo docker run -d -p 3000:3000 grafana/grafana
              sudo docker run -d -p 9090:9090 prom/prometheus
              EOF
}