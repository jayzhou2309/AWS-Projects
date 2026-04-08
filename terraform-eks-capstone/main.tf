module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source = "./modules/eks"
  cluster_name = "my-cluster-eks"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet1
}