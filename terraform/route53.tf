data "aws_route53_zone" "parent_zone" {
  name = var.parent_zone
}

# the subdomain
resource "aws_route53_zone" "demo_zone" {
  name              = var.demo_zone
  tags              = {}
  tags_all          = {}
}

resource "aws_route53_record" "demo_ns" {
  zone_id = data.aws_route53_zone.parent_zone.zone_id

  name = var.demo_zone
  type = "NS"
  ttl  = "300"

  records = aws_route53_zone.demo_zone.name_servers
}

