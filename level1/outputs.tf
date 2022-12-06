output "vpc-id" {
  value = module.vpc.vpc_id
}

output "subnet_id_public" {
  value = module.vpc.public_subnets
}

output "subnet_id_private" {
  value = module.vpc.private_subnets
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

