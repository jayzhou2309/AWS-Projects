variable "region" {
  description = "Default Region"
  type = string
  default = "us-east-1"
}

variable "profile" {
  description = "Default Profile"
  type = string
  default = "default"
}

variable "db_password" {
  sensitive = true
}

variable "cluster_name" {
  
}

