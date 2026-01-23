# CloudWatch Alarms – IAM Security Monitoring

## Scope & Objective

The goal of this section is to implement and validate **AWS-native security monitoring** for high-risk IAM activity using **CloudWatch metric filters and alarms**, backed by **CloudTrail logs**.

Rather than attempting to cover every possible IAM event, the focus is on **high-signal, low-noise detections** that are commonly used as early indicators of account compromise or misconfiguration.

All alarms were deployed via Infrastructure as Code (Terraform) and tested manually to validate expected behavior.

---
## Index

- [Architecture Overview](#overview)
- [Infrastructure as Code](#IaC)
- [Implemented CloudWatch Alarms](#alarms)
- [Testing & Validation](#testing)
- [Conclusion](#conclusion)

---
<a name="overview"></a>
## Architecture Overview

- **Source:** AWS CloudTrail (management events)
- **Log Destination:** CloudWatch Logs
- **Detection Mechanism:** CloudWatch Logs Metric Filters
- **Alerting:** CloudWatch Alarms

CloudTrail events are streamed into a centralized CloudWatch Log Group, where metric filters extract security-relevant signals that feed CloudWatch alarms.

---
<a name="IaC"></a>
## Infrastructure as Code

All CloudWatch log group, metric filters, and alarms were created using Terraform.

Relevant configuration can be found in:
- `/terraform/cloudwatch/main.tf`

---
<a name="alarms"></a>
## Implemented CloudWatch Alarms

### 1. IAM User Lifecycle Events

**Purpose**  
Monitor the creation and deletion of IAM users.

These actions may indicate:
- Legitimate administrative activity
- Unauthorized persistence mechanisms
- Post-compromise privilege manipulation

**Detection Logic**
- Tracks IAM lifecycle API calls such as:
  - `CreateUser`, `DeleteUser`
- Each matching event increments a metric

**Why This Matters**
- IAM changes often precede or follow privilege escalation
- Provides visibility into identity-related changes without deep inspection

**Alarm Output:**

<p align="center">
  <img src="./cloudwatch-alarms-tests/a1-iam-lifecycle-alarm.png" width="750">
</p>

---

### 2. Root Account Usage

**Purpose**  
Detect any usage of the AWS Root account.

Root credentials should never be used for day-to-day operations. Any activity involving the root account is considered **high severity** and warrants immediate investigation.

**Detection Logic**
- Matches CloudTrail events where `userIdentity.type = "Root"`
- Triggers an alarm on **any occurrence**

**Why This Matters**
- Root account usage bypasses IAM controls
- Common indicator in real-world breaches
- Strong signal with minimal false positives

**Alarm Output:**

<p align="center">
  <img src="./cloudwatch-alarms-tests/a2-root-account-usage-alarm.png" width="750">
</p>

---

### 3. Console Login Failures (Threshold-Based)

**Purpose**  
Detect repeated failed AWS Management Console login attempts.

This alarm is designed to highlight **potential misconfiguration, authentication issues, or credential misuse** while avoiding excessive noise from isolated failures.

**Detection Logic**
- Matches `ConsoleLogin` events with `responseElements.ConsoleLogin = "Failure"`
- Alarm triggers when **3 or more failures occur within the evaluation period**

**Important Limitation**
This alarm aggregates failures **at the account level**, not per user.

This means:
- Three different users failing once each will still trigger the alarm
- CloudWatch metric filters cannot natively correlate failures per individual identity
- The alarm by itself is not suficient to determine potential **brute-force attacks**

**Why This Is Still Useful**
- Flags abnormal authentication patterns early
- Works well as a **signal for further investigation**, not a final verdict

**Alarm Output:**

<p align="center">
  <img src="./cloudwatch-alarms-tests/a3-console-login-failure-alarm.png" width="750">
</p>

---
<a name="testing"></a>
## Testing & Validation

Each alarm was manually tested by generating corresponding events via:
- AWS CLI
- AWS Management Console

**IAM Lifecycle Alarm Testing Included:**
- Creating and deleting IAM User in quick succession via AWS CLI.
- Correlating timestamps of command usage and alarm trigger
- Commands used:

```bash
aws iam create-user --user-name cw-test-user
aws iam delete-user --user-name cw-test-user
```

**Root Account Usage Testing Included:**
- Manually logging into Root account for a few minutes
- Checking services such as Billing and IAM

**Console Login Failure Testing Included:**
- Purposefully failing logins 3 times in quick succession

Observed behavior:
- Alarms correctly transitioned to **ALARM** state upon detection
- Alarms automatically returned to **OK** after the evaluation window elapsed
- No manual acknowledgment or reset was required

This confirms correct metric extraction, alarm configuration, and expected CloudWatch behavior.

**Post-Evaluation Alarm Output:**

<p align="center">
  <img src="./cloudwatch-alarms-tests/alarms-OK.png" width="750">
</p>

---
<a name="conclusion"></a>
## Conclusion

This monitoring setup provides **practical, high-signal IAM detections** using AWS-native services, suitable for small-to-medium environments or as a foundation for more advanced security monitoring pipelines.

It emphasizes:
- Signal quality over quantity
- Operational realism
- Clear understanding of tool limitations