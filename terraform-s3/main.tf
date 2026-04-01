provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_s3_bucket" "tfs3_bucketzhoujunbai6969" {
    bucket = "tfs3-bucketzhoujunbai6969"
    website {
        index_document = "index.html"
        error_document = "error.html"
    }
}

resource "aws_s3_bucket_object" "index" {
    bucket = aws_s3_bucket.tfs3_bucketzhoujunbai6969.bucket
    key    = "index.html"
    source = "index.html"
}

resource "aws_s3_bucket_object" "error" {
    bucket = aws_s3_bucket.tfs3_bucketzhoujunbai6969.bucket
    key    = "error.html"
    source = "error.html"
}

resource "aws_s3_bucket_public_access_block" "tfs3_bucketzhoujunbai6969" {
    bucket = aws_s3_bucket.tfs3_bucketzhoujunbai6969.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "tfs3_bucketzhoujunbai6969_policy" {
    bucket = aws_s3_bucket.tfs3_bucketzhoujunbai6969.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.tfs3_bucketzhoujunbai6969.arn}/*"
            }
        ]
    })
}