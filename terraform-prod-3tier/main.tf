provider "aws" {
  profile = "default"
  region = "ap-southeast-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "compute" {
  source = "./modules/compute"
}

module "database" {
  source = "./modules/database"
}