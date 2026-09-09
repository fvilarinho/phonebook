resource "aws_iam_role" "phonebook_backup" {
  name = "${local.build.name}-backup"

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
  name = "${local.build.name}-backup"
  role = aws_iam_role.phonebook_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
  name = "${local.build.name}-database"
  role = aws_iam_role.phonebook_backup.name

  depends_on = [aws_iam_role.phonebook_backup]
}
