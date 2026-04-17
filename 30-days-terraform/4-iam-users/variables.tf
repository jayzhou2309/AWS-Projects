variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "iam_users" {
  type = list(string)
}

locals {
  users = csvdecode(file("users.csv"))
}

data "aws_caller_identity" "name" {
  
}

output "account_id" {
  value = data.aws_caller_identity.name
}

output "user_names" {
  value = [for users in local.users: "${user.first_name} ${user.last_name}"]
}