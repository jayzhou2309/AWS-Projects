provider "aws" {
  region = var.region
  profile = var.profile
}

# S3 Resource
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.bucket_name}_jj1"

  tags = {
    Name = "My Bucket" 
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name = "demo-oac"
  description = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}