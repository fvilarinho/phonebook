resource "aws_cloudtrail" "phonebook" {
  name           = "${local.prefix}-${local.build.name}-logs"
  s3_bucket_name = aws_s3_bucket.phonebook_logs.id
  s3_key_prefix  = "cloudtrail"

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [aws_s3_bucket_policy.phonebook_logs]
}