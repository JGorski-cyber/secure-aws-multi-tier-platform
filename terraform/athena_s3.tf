resource "aws_s3_bucket" "athena_results" {
    bucket = "cloud-foundation-athena-results-${var.aws_region}"

    tags = {
        Project     = "secure-aws-multi-tier-platform"
        Environment = "foundation"
        ManagedBy   = "Terraform"
        Purpose = "AthenaQueryResults"
        DataClassification = "Logs"
  }
}

resource "aws_s3_bucket_versioning" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}