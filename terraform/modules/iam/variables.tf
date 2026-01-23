variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "cloudtrail_s3_bucket_arn" {
  type = string
}