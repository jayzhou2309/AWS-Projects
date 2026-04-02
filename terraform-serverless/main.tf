provider "aws" {
    region = "us-east-1"
    profile = "default"
}

module "vpc" {
    source = "./modules/vpc"
}
module "compute" {
    source = "./modules/compute"
    dynamodb_table_arn = module.db.table_arn
}
module "db" {
    source = "./modules/db"
}