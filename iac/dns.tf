data "cloudflare_zone" "phonebook" {
  filter = {
    name = local.secrets.frontend.domain
  }
}

resource "cloudflare_dns_record" "phonebook_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.phonebook.domain_validation_options :

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

  depends_on = [aws_acm_certificate.phonebook]
}

resource "cloudflare_dns_record" "phonebook" {
  zone_id = data.cloudflare_zone.phonebook.id
  name    = "${local.secrets.frontend.host}.${local.secrets.frontend.domain}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.phonebook.domain_name
  ttl     = 60
  proxied = false

  depends_on = [
    data.cloudflare_zone.phonebook,
    aws_cloudfront_distribution.phonebook
  ]
}
