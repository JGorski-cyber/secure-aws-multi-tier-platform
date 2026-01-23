resource "aws_cloudtrail" "account_trail" {
  name                          = "cloud-foundation-account-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  cloud_watch_logs_group_arn = "${var.cloudwatch_log_group_arn}:*"
  cloud_watch_logs_role_arn = "${var.cloudwatch_log_role_arn}"


  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}


