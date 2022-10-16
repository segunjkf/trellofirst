module "lb" {
  source = "../modules/lb"

  env_code = var.env_code
  vpc_id   = data.terraform_remote_state.layer1.outputs.vpc-id
  subnets  = data.terraform_remote_state.layer1.outputs.subnet_id_public
}


