module "vpc" {
  source = "../modules/vpc"

  env_code     = var.env_code
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
  vpc_cidr     = var.vpc_cidr
}