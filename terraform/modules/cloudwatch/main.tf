resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "/aws/cloudtrail/management-events"
  retention_in_days = 90

  tags = {
    Project = "secure-aws-multi-tier-platform"
    Purpose = "CloudTrail-Management-Events"
  }
}

# ======================= #
# IAM Lifecycle Detection #
# ======================= #

resource "aws_cloudwatch_log_metric_filter" "iam_user_lifecycle" {
  name           = "IAMUserLifecycle"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name

  pattern = <<EOF
{ ($.eventSource = "iam.amazonaws.com") &&
  ($.eventName = "CreateUser" || $.eventName = "DeleteUser") }
EOF

  metric_transformation {
    name      = "IAMUserLifecycle"
    namespace = "Security/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_user_lifecycle_alarm" {
  alarm_name          = "iam-user-lifecycle-detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "IAMUserLifecycle"
  namespace           = "Security/CloudTrail"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "Detects IAM user creation or deletion"

  treat_missing_data = "notBreaching"
}

# ====================== #
# Root Account Detection #
# ====================== #

resource "aws_cloudwatch_log_metric_filter" "root_account_activity" {
  name           = "RootAccountActivity"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name

  pattern = <<EOF
{ $.userIdentity.type = "Root" }
EOF

  metric_transformation {
    name      = "RootAccountActivity"
    namespace = "Security/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_account_activity_alarm" {
  alarm_name          = "root-account-usage-detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootAccountActivity"
  namespace           = "Security/CloudTrail"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  alarm_description = "Detects ANY root account activity"
  treat_missing_data = "notBreaching"
}

# ===================== #
# Console Login Failure #
# ===================== #

resource "aws_cloudwatch_log_metric_filter" "console_login_failures" {
  name           = "console-login-failure"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name

  pattern = <<EOF
{ ($.eventName = "ConsoleLogin") && ($.responseElements.ConsoleLogin = "Failure") }
EOF

  metric_transformation {
    name      = "ConsoleLoginFailureCount"
    namespace = "Security/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_login_failure_alarm" {
  alarm_name          = "console-login-failures-detected"
  alarm_description   = "Triggers on 3 or more failed AWS Console login attempts (Universal)"

  namespace           = "Security/CloudTrail"
  metric_name         = "ConsoleLoginFailureCount"
  statistic           = "Sum"

  period              = 300   # 5 minutes
  evaluation_periods  = 1
  threshold           = 3
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data  = "notBreaching"

  alarm_actions       = [] # No SNS for now
}
