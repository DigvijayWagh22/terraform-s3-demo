provider "aws" {
  region = var.region
}

# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  force_destroy = true

  tags = {
    Name = "AKMSPL Static Site"
  }
}

# Disable Block Public Access (this is required for public policy to work)
resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy to Allow Public Access to All Objects
resource "aws_s3_bucket_policy" "static_policy" {
  bucket = aws_s3_bucket.static_site.id

  # 🚨 Ensure this runs after access block is disabled
  depends_on = [aws_s3_bucket_public_access_block.allow_public_access]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}
