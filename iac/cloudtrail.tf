resource "aws_cloudtrail" "phonebook" {
  name                          = "${local.prefix}-${local.build.name}-logs"
  s3_bucket_name                = aws_s3_bucket.phonebook_logs.id
  s3_key_prefix                 = "audit"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.phonebook_logs]
}