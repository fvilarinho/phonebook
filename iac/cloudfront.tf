resource "aws_cloudfront_origin_access_control" "phonebook_static" {
  name                              = "${local.build.name}_static_oac"
  description                       = "OAC for static content bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "phonebook_static" {
  name        = "${local.build.name}_static_cache_policy"
  default_ttl = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

data "aws_cloudfront_cache_policy" "phonebook_dynamic" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_origin_request_policy" "phonebook" {
  name = "${local.build.name}_origin_request_policy"

  query_strings_config {
    query_string_behavior = "all"
  }

  headers_config {
    header_behavior = "allViewer"
  }

  cookies_config {
    cookie_behavior = "all"
  }
}

resource "aws_cloudfront_response_headers_policy" "phonebook" {
  name = "${local.build.name}_origin_response_policy"

  remove_headers_config {
    items {
      header = "Server"
    }
    items {
      header = "X-Powered-By"
    }
  }

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "camera=(), microphone=()"
      override = true
    }

    items {
      header   = "X-Robots-Tag"
      value    = "noindex, nofollow"
      override = true
    }
  }
}

resource "aws_cloudfront_distribution" "phonebook" {
  aliases         = [ "${local.secrets.frontend.host}.${local.secrets.frontend.domain}" ]
  enabled         = true
  is_ipv6_enabled = true
#  web_acl_id      = aws_wafv2_web_acl.app.arn

  # TLS certificate definition.
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.phonebook.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Static origin.
  origin {
    origin_id                = "${local.build.name}_static"
    domain_name              = aws_s3_bucket.phonebook_static.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.phonebook_static.id
  }

  # Dynamic origin.
  origin {
    origin_id   = "${local.build.name}_dynamic"
    domain_name = aws_lb.phonebook_cluster.dns_name

    origin_shield {
      enabled              = true
      origin_shield_region = data.aws_region.current.region
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default behavior.
  default_cache_behavior {
    target_origin_id           = "${local.build.name}_dynamic"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.phonebook_dynamic.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.phonebook.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.phonebook.id
  }

  ordered_cache_behavior {
    target_origin_id           = "${local.build.name}_static"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    path_pattern               = "/static/*"
    cache_policy_id            = aws_cloudfront_cache_policy.phonebook_static.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.phonebook.id
  }

  # Cache 404 errors.
  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 300
  }

  # Geo block restrictions. It's empty because the restrictions are being made in WAF.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  # # Logging definition.
  # logging_config {
  #   bucket          = aws_s3_bucket.app_logs.bucket_domain_name
  #   prefix          = "cloudfront/"
  #   include_cookies = true
  # }

  tags = {
    "Name"        = "${local.build.name}_cf"
    "auto-delete" = "no"
    "auto-stop"   = "no"
  }

  depends_on = [
    aws_acm_certificate.phonebook,
    #aws_s3_bucket.app_logs,
    aws_s3_bucket.phonebook_static,
    aws_lb.phonebook_cluster,
    aws_cloudfront_origin_access_control.phonebook_static,
    #aws_wafv2_web_acl.app,
    aws_cloudfront_cache_policy.phonebook_static,
    data.aws_cloudfront_cache_policy.phonebook_dynamic,
    aws_cloudfront_origin_request_policy.phonebook,
    aws_cloudfront_response_headers_policy.phonebook
  ]
}

# Enables the monitoring.
resource "aws_cloudfront_monitoring_subscription" "app" {
  distribution_id = aws_cloudfront_distribution.phonebook.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }

  depends_on = [aws_cloudfront_distribution.phonebook]
}
