resource "aws_wafv2_web_acl" "phonebook" {
  name        = "${local.prefix}-${local.build.name}-waf"
  description = "WAF ACL to protect against L3/L4 and L7 attacks - allowlist model"
  scope       = "CLOUDFRONT"

  # Blocks if there is no match with the allow rules (allowlist model).
  # Empty allowed_ips AND allowed_geos => no allow rule is created => all traffic blocked.
  default_action {
    block {}
  }

  # Enables monitoring.
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFProtectionACL"
    sampled_requests_enabled   = true
  }

  # Rate-based rule to mitigate L3/L4 volumetric attacks.
  # Evaluated before the allow rules so admitted traffic is still rate limited.
  rule {
    name     = "rate_limit"
    priority = 0

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = 1000
        aggregate_key_type    = "FORWARDED_IP"
        evaluation_window_sec = 60

        forwarded_ip_config {
          header_name       = "X-Forwarded-For"
          fallback_behavior = "MATCH"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # Size constraint to block oversized requests (L7 - slow POST attacks).
  rule {
    name     = "body_inspection_constraint"
    priority = 1

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = var.waf.restrictions.body_size

        field_to_match {
          body {
            oversize_handling = "MATCH"
          }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SizeConstraintRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - IP Reputation (blocks known malicious IPs - L3/L4).
  rule {
    name     = "ip_reputation"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSIPReputationRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - Anonymous IP List (L3/L4 protection).
  rule {
    name     = "anonymous_ip"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSAnonymousIPRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - Common Rule Set (L7 - OWASP Top 10).
  rule {
    name     = "owasp"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRules"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - SQL Injection (L7).
  rule {
    name     = "sqli"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSSQLiRules"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - Known Bad Inputs (L7).
  rule {
    name     = "known_bad_inputs"
    priority = 6

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSKnownBadInputsRules"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - Linux OS (L7)
  rule {
    name     = "exploitation"
    priority = 7

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSLinuxRules"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule - Bot Control (L7).
  rule {
    name     = "bot_control"
    priority = 8

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSBotControlRules"
      sampled_requests_enabled   = true
    }
  }

  # Allowlist rule - admits requests from approved IPs.
  # Created only when allowed_ips is non-empty. Evaluated after the protection
  # rules above, so admitted traffic is still scanned by the managed rule groups.
  dynamic "rule" {
    for_each = length(var.waf.restrictions.allowed_ips) > 0 ? [1] : []

    content {
      name     = "allowed_ips"
      priority = 9

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.phonebook_allowed_ips.arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowedIPSetRule"
        sampled_requests_enabled   = true
      }
    }
  }

  # Allowlist rule - admits requests from approved countries.
  # Created only when allowed_geos is non-empty (geo_match requires >= 1 code).
  # Combined with allowed_ips as OR: a request matching either allow rule passes.
  dynamic "rule" {
    for_each = length(var.waf.restrictions.allowed_geos) > 0 ? [1] : []

    content {
      name     = "allowed_geos"
      priority = 10

      action {
        allow {}
      }

      statement {
        geo_match_statement {
          country_codes = var.waf.restrictions.allowed_geos
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowedGeoRule"
        sampled_requests_enabled   = true
      }
    }
  }

  depends_on = [aws_wafv2_ip_set.phonebook_allowed_ips]
}

resource "aws_wafv2_ip_set" "phonebook_allowed_ips" {
  name               = "${local.prefix}-${local.build.name}-allowed-ips"
  description        = "IP set for allowing specific IPv4 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.waf.restrictions.allowed_ips

  tags = {
    "Name" = "${local.prefix}-${local.build.name}-allowed-ips"
  }
}

# Enables the logging and attach it to Cloudwatch logs.
# resource "aws_wafv2_web_acl_logging_configuration" "phonebook" {
#   log_destination_configs = [aws_cloudwatch_log_group.app.arn]
#   resource_arn            = aws_wafv2_web_acl.phonebook.arn
#
#   logging_filter {
#     default_behavior = "KEEP"
#
#     filter {
#       behavior    = "KEEP"
#       requirement = "MEETS_ANY"
#
#       condition {
#         action_condition {
#           action = "BLOCK"
#         }
#       }
#     }
#   }
#
#   depends_on = [
#     aws_cloudwatch_log_group.phone,
#     aws_wafv2_web_acl.phonebook
#   ]
# }
