module "vpc" {
  source = "../modules/vpc"

  env_code     = var.env_code
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
  vpc_cidr     = var.vpc_cidr
}
<<<<<<< HEAD



=======
  
  
  
>>>>>>> 1b948e4dc24809b61abeb04cd4bcff3915b4404a
