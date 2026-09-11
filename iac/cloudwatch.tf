resource "aws_cloudwatch_log_group" "phonebook_waf" {
  name              = "aws-waf-logs-${local.prefix}-${local.build.name}"
  retention_in_days = 30

  tags = {
    "Name" = "${local.prefix}-${local.build.name}-waf-logs"
  }
}

resource "aws_cloudwatch_metric_alarm" "phonebook_waf_blocked_requests" {
  alarm_name          = "${local.prefix}-${local.build.name}-waf-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 10
  statistic           = "SampleCount"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  alarm_description   = "Alarm to detect WAF blocked requests"
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = aws_wafv2_web_acl.phonebook.name
    Rule   = "ALL"
  }

  depends_on = [aws_wafv2_web_acl.phonebook]
}
