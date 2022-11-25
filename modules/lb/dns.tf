data "aws_route53_zone" "main" {
  name = "kaytheog.com"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${data.aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main-elb.dns_name]
}

