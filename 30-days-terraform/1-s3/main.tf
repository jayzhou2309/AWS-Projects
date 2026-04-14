provider "aws" {
  region = var.region
  profile = var.profile
}

# S3 Resource
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "zhoujunbai_tf_jj1"

  tags = {
    Name = "My Bucket" 
    Environment = "Dev"
  }
}