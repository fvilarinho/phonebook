resource "aws_iam_role" "phonebook_backup" {
  name = "${local.prefix}-${local.build.name}-backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "phonebook_backup" {
  name = "${local.prefix}-${local.build.name}-backup"
  role = aws_iam_role.phonebook_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:RunInstances"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.phonebook_backup.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.phonebook_backup.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.phonebook_backup.arn
      },
    ]
  })

  depends_on = [
    aws_iam_role.phonebook_backup,
    aws_s3_bucket.phonebook_backup
  ]
}

resource "aws_iam_instance_profile" "phonebook_database" {
  name = "${local.prefix}-${local.build.name}-database"
  role = aws_iam_role.phonebook_backup.name

  depends_on = [aws_iam_role.phonebook_backup]
}

resource "aws_iam_role" "phonebook_logs" {
  name = "${local.prefix}-${local.build.name}-logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "phonebook_logs" {
  name = "${local.prefix}-${local.build.name}-logs"
  role = aws_iam_role.phonebook_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.phonebook_logs.arn}/backend/*"
      }
    ]
  })

  depends_on = [
    aws_iam_role.phonebook_logs,
    aws_s3_bucket.phonebook_logs
  ]
}

resource "aws_iam_instance_profile" "phonebook_cluster_workernode" {
  name = "${local.prefix}-${local.build.name}-cluster-workernode"
  role = aws_iam_role.phonebook_logs.name

  depends_on = [aws_iam_role.phonebook_logs]
}
