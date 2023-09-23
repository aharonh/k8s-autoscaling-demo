variable "demo_state_bucket" {
    type = string
    description = "demo state bucket name"
    default = "demo-harley-systems-state"
}

variable "demo_aws_profile" {
    type = string
    description = "demo aws profile name"
    default = "harley-systems-mfa"
}

variable "demo_region" {
    type = string
    description = "demo region name"
    default = "us-east-1"
}

variable "demo_oidc_bucket" {
    type = string
    description = "demo oidc bucket name"
    default = "demo-harley-systems-oidc"
}

variable "parent_zone" {
    type = string
    description = "parent zone name"
    default = "harley.systems"
}

variable "demo_zone" {
    type = string
    description = "demo zone name"
    default = "demo.harley.systems"
}

variable "certificate_name_tag" {
  type = string
  description = "value for the tag 'Name' in the certificate"
  default = "demo"
}

variable "certificate_names" {
  type = list(map(string))
  description = <<EOF
  [{
    # Subject Name for the certificate.
    # The first name will be the SN (Subject Name) and the rest will be the SAN (Subject Alternative Name)
    "subject" = "*.example.com",
    # Name of the hosted zone in route53 that holds the records for 'subject'
    "hosted_zone_name" = "example.com"
  }]
  EOF
  
  default =   [
        {
            # The first name will be the SN (Subject Name) and the rest will be the SAN (Subject Alternative Name)
            "subject" = "*.demo.harley.systems",
            # Name of the hosted zone in route53 that holds the records for 'subject'
            "hosted_zone_name" = "demo.harley.systems"
        }
    ]
}

