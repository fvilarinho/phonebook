# Creates the bucket to store static content.
resource "aws_s3_bucket" "phonebook_static" {
  bucket        = "${var.settings.general.name}-static"
  force_destroy = true
}

resource "aws_s3_bucket" "phonebook_database" {
  bucket        = "${var.settings.general.name}-database"
  force_destroy = true
}

# Buckets BPA.
resource "aws_s3_bucket_public_access_block" "phonebook_static" {
  bucket                  = aws_s3_bucket.phonebook_static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [ aws_s3_bucket.phonebook_static ]
}

resource "aws_s3_bucket_public_access_block" "phonebook_database" {
  bucket                  = aws_s3_bucket.phonebook_database.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [ aws_s3_bucket.phonebook_database ]
}

# Uploads all static content files.
resource "aws_s3_object" "phonebook_static" {
  for_each = fileset(abspath(pathexpand("../src/main/static")), "**")

  bucket       = aws_s3_bucket.phonebook_static.id
  key          = each.value
  source       = abspath(pathexpand("../src/main/static/${each.value}"))
  etag         = filemd5(abspath(pathexpand("../src/main/static/${each.value}")))
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

  depends_on = [ aws_s3_bucket.phonebook_static ]
}
