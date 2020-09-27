resource "aws_s3_bucket" "template_bucket" {
  bucket = lower(local.bucket_name_concat)
  acl    = "private"

  tags = {
    Name        = upper(local.bucket_name_concat)
    Environment = var.environment
  }
  force_destroy = true
}

locals {
  bucket_name_concat = "${var.account_id}-${var.environment}-${var.bucket_name}-${var.suffix}"
}