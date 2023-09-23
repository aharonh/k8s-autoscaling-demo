locals {
  # the first name in "names" variable will be the Subject Name of the certificate; 
  # the rest, if exist, will be Subject Alternative Names
  subject_alternative_names = length(var.certificate_names) > 1 ? slice(var.certificate_names, 1, length(var.certificate_names)) : []
  validation_options = tolist(aws_acm_certificate.certificate.domain_validation_options)
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.certificate_names[0].subject
  validation_method = "DNS"
  subject_alternative_names = [for san in local.subject_alternative_names: san.subject]
  tags = {
    Name = var.certificate_name_tag
  }
 
  lifecycle {
    create_before_destroy = true
  } 
}

resource "aws_route53_record" "record" {
  # Domain validation options and var.certificate_names are always the same length
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone[each.key].zone_id

}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}

data "aws_route53_zone" "zone" {
  for_each = {
    for n in var.certificate_names: n.subject => n.hosted_zone_name
  }

  name         = each.value
  private_zone = false
}
