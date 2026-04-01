provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_instance" "my_instance" {
    ami           = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
    instance_type = var.instance_type
    
    tags = {
        Name = var.instance_tags["Name"]
    }
}
