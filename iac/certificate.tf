resource "tls_private_key" "phonebook" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_acm_certificate" "phonebook" {
  domain_name       = "${local.secrets.frontend.host}.${local.secrets.frontend.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "phonebook" {
  certificate_arn = aws_acm_certificate.phonebook.arn

  validation_record_fqdns = [
    for option in aws_acm_certificate.phonebook.domain_validation_options : option.resource_record_name
  ]

  depends_on = [
    aws_acm_certificate.phonebook,
    cloudflare_dns_record.phonebook_certificate_validation
  ]
}
