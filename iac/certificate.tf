resource "tls_private_key" "phonebook" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_acm_certificate" "phonebook_cluster" {
  domain_name       = "${var.settings.general.name}.${var.settings.general.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "phonebook_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.phonebook_cluster.domain_validation_options :

    option.domain_name => {
      name    = trimsuffix(option.resource_record_name, ".")
      type    = option.resource_record_type
      content = option.resource_record_value
    }
  }

  zone_id = data.cloudflare_zone.phonebook.id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = 60
  proxied = false

  depends_on = [aws_acm_certificate.phonebook_cluster]
}

resource "aws_acm_certificate_validation" "phonebook_cluster" {
  certificate_arn = aws_acm_certificate.phonebook_cluster.arn

  validation_record_fqdns = [
    for option in aws_acm_certificate.phonebook_cluster.domain_validation_options : option.resource_record_name
  ]

  depends_on = [
    aws_acm_certificate.phonebook_cluster,
    cloudflare_dns_record.phonebook_certificate_validation
  ]
}

resource "cloudflare_dns_record" "phonebook_cluster" {
  zone_id = data.cloudflare_zone.phonebook.id
  name    = "${var.settings.general.name}.${var.settings.general.domain}"
  type    = "CNAME"
  content = aws_lb.phonebook_cluster.dns_name
  ttl     = 60
  proxied = false

  depends_on = [aws_lb.phonebook_cluster]
}

data "cloudflare_zone" "phonebook" {
  filter = {
    name = var.settings.general.domain
  }
}
