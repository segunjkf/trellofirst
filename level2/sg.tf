module "external_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "$(var.env_code)-external"
  vpc_id = data.terraform_remote_state.layer1.outputs.vpc-id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS FROM ANYWHERE TO ELB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "TCP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "$(var.env_code)-private"
  vpc_id = data.terraform_remote_state.layer1.outputs.vpc-id

  computed_ingress_with_source_security_group_id = [
    {
      rule   = "https-80-tcp"
      source = module.external_sg.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

