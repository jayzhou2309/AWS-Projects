variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "solution_stack_name" {
  description = "Beanstalk solution stack name"
  type = string
  default = "64bit Amazon Linux 2023 v6.6.8 running Node.js 20"
}

variable "instance_type" {
  description = "EC2 Instance type for Beanstalk Env"
  type = string
  default = "t3.micro"
}

variable "bucket-name" {
  default = "zhoujunbai-tf-bucket"
}

variable "tags" {
  description = "Tags to apply to all resource"
  type = map(string)
  default = {
    "Project" = "BlueGreenDeployment"
    "Env" = "Demo"
    "ManagedBy" = "Terraform"
  }
}

variable "app_name" {
  default = "zhoujunbai-tf"
}