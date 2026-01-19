resource "aws_cloudtrail" "account_trail" {
  name                          = "cloud-foundation-account-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.cloudtrail_cloudwatch_role.arn


  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
