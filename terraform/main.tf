module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "cloudtrail" {
  source     = "./modules/cloudtrail"
  aws_region = var.aws_region
  cloudwatch_log_group_arn   = module.cloudwatch.cloudtrail_cloudwatch_log_group_arn
  cloudwatch_log_role_arn = module.cloudwatch.cloudtrail_cloudwatch_role_arn
}

module "athena" {
  source = "./modules/athena"
  aws_region = var.aws_region
}

module "iam" {
  source = "./modules/iam"
  cloudtrail_s3_bucket_arn = module.cloudtrail.cloudtrail_s3_bucket_arn
}
