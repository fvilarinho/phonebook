resource "aws_config_configuration_recorder" "phonebook" {
  name     = "${local.prefix}-${local.build.name}"
  role_arn = aws_iam_role.phonebook_logs.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }

  depends_on = [aws_iam_role.phonebook_logs]
}

resource "aws_config_delivery_channel" "phonebook" {
  name           = "${local.prefix}-${local.build.name}"
  s3_bucket_name = aws_s3_bucket.phonebook_logs.id
  s3_key_prefix  = "config"

  depends_on = [aws_config_configuration_recorder.phonebook]
}

resource "aws_config_configuration_recorder_status" "phonebook" {
  name       = aws_config_configuration_recorder.phonebook.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.phonebook]
}

resource "aws_config_config_rule" "phonebook_bpa" {
  name = "${local.prefix}-${local.build.name}-bpa"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder_status.phonebook]
}

resource "aws_config_config_rule" "phonebook_remote_access" {
  name = "${local.prefix}-${local.build.name}-remote-access"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder_status.phonebook]
}

resource "aws_config_config_rule" "phonebook_approved_amis" {
  name = "${local.prefix}-${local.build.name}-approved-amis"

  source {
    owner             = "AWS"
    source_identifier = "APPROVED_AMIS_BY_ID"
  }

  input_parameters = jsonencode({amiIds = var.compute.approved_ami_id})

  depends_on = [aws_config_configuration_recorder_status.phonebook]
}