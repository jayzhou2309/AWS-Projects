variable "region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "us-east-1"
}

variable "profile" {
    description = "AWS Profile"
    type        = string
    default     = "default"
}