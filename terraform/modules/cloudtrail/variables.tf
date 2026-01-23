variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "cloudwatch_log_group_arn" {
  type = string
}

variable "cloudwatch_log_role_arn" {
  type = string
}

