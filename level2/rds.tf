module "rds" {
  source = "../modules/rds"

  subnet_ids            = data.terraform_remote_state.layer1.outputs.subnet_id_private
  env_code              = var.env_code
  vpc_id                = data.terraform_remote_state.layer1.outputs.vpc-id
  source_Security_group = module.asg.security_group_id
  rds_password          = local.rds_password
}