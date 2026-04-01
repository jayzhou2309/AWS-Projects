provider "aws" {
  region = var.region
  profile = "default"
}

module "vpc" {
  source = "/modules/vpc"

  cidr_block = "10.0.0.0/16"
}

module "web" {
  source = "/modules/web"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}

module "database" {
  source = "/modules/database"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}