module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name = "${var.env_code}-rds"

  vpc_id = data.terraform_remote_state.layer1.outputs.vpc-id

  computed_ingress_with_source_security_group_id = [
    {
      rule   = "https-80-tcp"
      source_security_group_id = module.private_sg.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "TCP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier             = var.env_code
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  port                   = "3306"
  db_name                = "mydb"
  username               = "admin"
  password               = local.rds_password
  create_random_password = false

  skip_final_snapshot = true
  multi_az            = true

  vpc_security_group_ids = [module.external_sg.security_group_id]

  backup_retention_period = 25
  backup_window           = "21:00-23:00"

  create_db_subnet_group = true
  subnet_ids             = data.terraform_remote_state.layer1.outputs.subnet_id_private

  family               = "mysql5.7"
  major_engine_version = "5.7"
}

