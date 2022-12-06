data "aws_route53_zone" "main" {
  name = "kaytheog.com"
}


module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name = "www.kaytheog.com"
  zone_id     = data.aws_route53_zone.main.zone_id

  wait_for_validation = true
}

