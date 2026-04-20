provider "aws" {
  region = var.region
  profile = var.profile
}

resource "aws_iam_role" "eb_ec2_role" {
  name = "${var.app_name}-eb-ec2-role"

  assume_role_policy = jsonencode({
    
  })
}