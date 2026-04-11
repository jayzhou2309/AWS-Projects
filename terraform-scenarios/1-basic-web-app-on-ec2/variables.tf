variable "region" {
  description = "Default Region"
  type = string
  default = "us-east-1"
}

variable "profile" {
  description = "Default Profile"
  type = string
  default = "default"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t3.micro"
}

variable "ami" {
  description = "EC2 AMI"
  type = string
  default = "ami-0c94855ba95c71c99"
}


# Autofetch My IP
data "http" "my_ip" {
  url = "https://ifconfig.me"
}