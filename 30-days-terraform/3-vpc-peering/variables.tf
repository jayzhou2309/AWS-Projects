variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  my_ip = chomp(data.http.my_ip.response_body)
}