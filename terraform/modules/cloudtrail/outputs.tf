output "cloudtrail_s3_bucket_arn" {
  value = aws_s3_bucket.cloudtrail_logs.arn
}