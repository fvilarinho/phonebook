resource "aws_s3_bucket" "phonebook_static" {
  bucket        = "${local.prefix}-${local.build.name}-static"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "phonebook_static" {
  bucket                  = aws_s3_bucket.phonebook_static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.phonebook_static]
}

resource "aws_s3_bucket_policy" "phonebook_static" {
  bucket = aws_s3_bucket.phonebook_static.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.phonebook_static.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.phonebook.arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.phonebook_static,
    aws_s3_bucket_public_access_block.phonebook_static,
    aws_cloudfront_distribution.phonebook
  ]
}

resource "aws_s3_object" "phonebook_static" {
  for_each = fileset(abspath(pathexpand("../src/main/static")), "**")

  bucket = aws_s3_bucket.phonebook_static.id
  key    = "static/${each.value}"
  source = abspath(pathexpand("../src/main/static/${each.value}"))
  etag   = filemd5(abspath(pathexpand("../src/main/static/${each.value}")))
  content_type = lookup(
    {
      "html"  = "text/html"
      "css"   = "text/css"
      "js"    = "application/javascript"
      "json"  = "application/json"
      "png"   = "image/png"
      "jpg"   = "image/jpeg"
      "jpeg"  = "image/jpeg"
      "gif"   = "image/gif"
      "svg"   = "image/svg+xml"
      "ico"   = "image/x-icon"
      "mp3"   = "audio/mpeg"
      "woff"  = "font/woff"
      "woff2" = "font/woff2"
      "ttf"   = "font/ttf"
      "txt"   = "text/plain"
      "xml"   = "application/xml"
    },
    reverse(split(".", each.value))[0],
    "application/octet-stream"
  )

  depends_on = [aws_s3_bucket.phonebook_static]
}

resource "aws_s3_bucket" "phonebook_backup" {
  bucket        = "${local.prefix}-${local.build.name}-backup"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "phonebook_backup" {
  bucket                  = aws_s3_bucket.phonebook_backup.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.phonebook_backup]
}

resource "aws_s3_bucket_policy" "phonebook_backup" {
  bucket = aws_s3_bucket.phonebook_backup.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = "${aws_s3_bucket.phonebook_backup.arn}"
      },
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.phonebook_backup.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.phonebook_backup,
    aws_s3_bucket_public_access_block.phonebook_backup
  ]
}

resource "aws_s3_bucket" "phonebook_logs" {
  bucket        = "${local.prefix}-${local.build.name}-logs"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "phonebook_logs" {
  bucket = aws_s3_bucket.phonebook_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket.phonebook_logs]
}

resource "aws_s3_bucket_acl" "phonebook_logs" {
  bucket = aws_s3_bucket.phonebook_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket.phonebook_logs,
    aws_s3_bucket_ownership_controls.phonebook_logs
  ]
}
