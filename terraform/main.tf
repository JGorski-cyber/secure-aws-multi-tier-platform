resource "aws_s3_bucket" "foundation" {
  bucket = "cloud-foundation-baseline-${var.aws_region}"

  tags = {
    Project     = "secure-aws-multi-tier-platform"
    Environment = "foundation"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "foundation" {
  bucket = aws_s3_bucket.foundation.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "foundation" {
  bucket = aws_s3_bucket.foundation.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "foundation" {
  bucket = aws_s3_bucket.foundation.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


