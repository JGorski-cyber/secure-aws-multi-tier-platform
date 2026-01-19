resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "/aws/cloudtrail/management-events"
  retention_in_days = 90

  tags = {
    Project = "secure-aws-multi-tier-platform"
    Purpose = "CloudTrail-Management-Events"
  }
}
