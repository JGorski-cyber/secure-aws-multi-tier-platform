-- Detecting basic IAM Lifecycle
SELECT
  eventTime,
  eventName,
  userIdentity.type,
  userIdentity.arn,
  requestParameters
FROM cloudtrail_logs.cloudtrail_events
WHERE eventSource = 'iam.amazonaws.com'
  AND eventName IN (
    'CreateUser', 'DeleteUser',
    'CreateRole', 'DeleteRole',
    'AttachUserPolicy', 'DetachUserPolicy',
    'AttachRolePolicy', 'DetachRolePolicy',
    'PutUserPolicy', 'DeleteUserPolicy',
    'PutRolePolicy', 'DeleteRolePolicy'
  )
ORDER BY eventTime DESC;

-- Detecting Console vs API usage
SELECT
  eventTime,
  eventName,
  userIdentity.type,
  userIdentity.arn,
  sourceIPAddress,
  userAgent
FROM cloudtrail_logs.cloudtrail_events
WHERE userIdentity.type IN ('IAMUser', 'AssumedRole')
ORDER BY eventTime DESC
LIMIT 50;

-- Detecing basic Privilege Escalation attempt
SELECT
  eventName,
  eventTime,
  userIdentity.arn,
  json_extract_scalar(requestParameters, '$.policyArn') AS policy_arn
FROM cloudtrail_logs.cloudtrail_events
WHERE eventSource = 'iam.amazonaws.com'
  AND eventName IN ('AttachUserPolicy', 'AttachRolePolicy')
  AND json_extract_scalar(requestParameters, '$.policyArn') LIKE '%AdministratorAccess%'
ORDER BY eventTime DESC;

-- Detecting Root account usage
SELECT
  eventTime,
  eventName,
  sourceIPAddress,
  userAgent
FROM cloudtrail_logs.cloudtrail_events
WHERE userIdentity.type = 'Root'
ORDER BY eventTime DESC;

-- Detecting Failed or Denied Actions
SELECT
  eventTime,
  eventName,
  errorCode,
  errorMessage,
  userIdentity.arn
FROM cloudtrail_logs.cloudtrail_events
WHERE errorCode IS NOT NULL
ORDER BY eventTime DESC;