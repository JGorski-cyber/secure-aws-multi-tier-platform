data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "security_operator_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "security_operator_permissions" {

  # CloudTrail logs in S3
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs.arn,
      "${aws_s3_bucket.cloudtrail_logs.arn}/*"
    ]
  }

  # Athena access
  statement {
    effect = "Allow"

    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:ListDatabases",
      "athena:ListTableMetadata"
    ]

    resources = ["*"]
  }

  # Permission to access Athena's results s3
  statement {
    sid = "AthenaQueryResultsAccess"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::cloud-foundation-athena-results-us-east-1",
      "arn:aws:s3:::cloud-foundation-athena-results-us-east-1/*"
    ]
  }

  # Permission to write to Athena's result s3
  statement {
    sid = "AthenaQueryResultsWrite"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::cloud-foundation-athena-results-us-east-1/*"
    ]
  }

  # Glue metadata (required by Athena)
  statement {
    effect = "Allow"

    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables"
    ]

    resources = ["*"]
  }

  # CloudWatch Logs (read-only)
  statement {
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "security_operator" {
  name               = "SecurityOperatorReadOnlyRole"
  assume_role_policy = data.aws_iam_policy_document.security_operator_trust.json
}

resource "aws_iam_policy" "security_operator_policy" {
  name   = "SecurityOperatorReadOnlyPolicy"
  policy = data.aws_iam_policy_document.security_operator_permissions.json
}

resource "aws_iam_role_policy_attachment" "security_operator_attach" {
  role       = aws_iam_role.security_operator.name
  policy_arn = aws_iam_policy.security_operator_policy.arn
}

