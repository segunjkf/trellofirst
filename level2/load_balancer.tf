module "elb" {
  source = "terraform-aws-modules/alb/aws"

  name = var.env_code

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.layer1.outputs.vpc-id
  internal        = false
  subnets         = data.terraform_remote_state.layer1.outputs.subnet_id_public
  security_groups = [module.external_sg.security_group_id]

  target_groups = [
    {
      name_prefix          = "main"
      backend_protocol     = "HTTP"
      backend_port         = 80
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      action_type        = "forward"
      target_group_index = 0
    }
  ]
}

module "dns" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.main.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      records = [module.elb.lb_dns_name]
      ttl     = 3600
    }
  ]
}


