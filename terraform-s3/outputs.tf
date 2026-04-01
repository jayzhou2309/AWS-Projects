output "bucket_name" {
    description = "Bucket Name"
    value       = aws_s3_bucket.tfs3_bucketzhoujunbai6969
}

output "website_endpoint" {
    description = "Public Endpoint for S3 Website"
    value       = aws_s3_bucket.tfs3_bucketzhoujunbai6969.website_endpoint
}

output "index_url" {
    description = "Direct URL to index.html file"
    value = "http://${aws_s3_bucket.tfs3_bucketzhoujunbai6969.website_endpoint}/index.html"
}

output "error_url" {
    description = "Direct URL to error.html file"
    value = "http://${aws_s3_bucket.tfs3_bucketzhoujunbai6969.website_endpoint}/error.html"
}