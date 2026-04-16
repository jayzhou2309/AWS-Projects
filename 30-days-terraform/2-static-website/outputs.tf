output "bucket_access_url" {
  value = aws_s3_bucket.demo_bucket_name.bucket_regional_domain_name
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cf_dist.domain_name
}