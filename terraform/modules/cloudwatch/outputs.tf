output "cloudtrail_cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.cloudtrail_log_group.arn
}

output "cloudtrail_cloudwatch_role_arn" {
  value = aws_iam_role.cloudtrail_cloudwatch_role.arn
}