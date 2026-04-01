provider "aws" {
  profile = "default"
  region = var.region
}

resource "aws_instance" "webapp" {
ami = var.ami
instance_type = var.instance_type

vpc_security_group_ids = [aws_security_group.webapp_sg.id]

key_name = "demo-keypair"

tags = {
  Name = "Terraform Web Server"
}

user_data = <<-EOF
#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
EOF
}

resource "aws_security_group" "webapp_sg" {
  name = "webapp_sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Enable ICMP (ping) access
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

