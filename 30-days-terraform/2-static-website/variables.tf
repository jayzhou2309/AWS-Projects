variable "region" {
  description = "Default Regions"
  type = string
  default = "us-east-1"
}

variable "profile" {
  description = "Default Profile"
  type = string
  default = "default"
}

variable "bucket_name" {
  default = "zhoujunbai-tf"
}

locals {
  origin_id = "S3-${aws_s3_bucket.demo_bucket_name.id}"
}