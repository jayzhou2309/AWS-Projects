provider "aws" {
  region = var.region
  profile = var.profile
}

# S3 Resource
resource "aws_s3_bucket" "demo_bucket_name" {
  bucket = "${replace(var.bucket_name, "_", "-")}-jj13579"

  tags = {
    Name = "My Bucket" 
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.demo_bucket_name.id

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

resource "aws_s3_bucket_policy" "allow_cf" {
  bucket = aws_s3_bucket.demo_bucket_name.id
  depends_on = [ aws_s3_bucket_public_access_block.block ]
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipal",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.demo_bucket_name.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cf_dist.arn
          }
        }
      }
    ]
  })
}

# Uploading files to S3
resource "aws_s3_object" "object" {
  for_each = fileset("${path.module}/www", "**/*")
  bucket = aws_s3_bucket.demo_bucket_name.id
  key = each.value
  source = "${path.module}/www/${each.value}"
  etag = filemd5("${path.module}/www/${each.value}")  
  content_type = lookup({
    "html" = "text/html",
    "css" = "text/css",
    "js" = "application/javascript"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

# CF Distribution
resource "aws_cloudfront_distribution" "cf_dist" {
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.demo_bucket_name.bucket_regional_domain_name
    origin_id = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

