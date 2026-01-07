output "foundation_bucket_name" {
  description = "Name of the foundation S3 bucket"
  value       = aws_s3_bucket.foundation.bucket
}
