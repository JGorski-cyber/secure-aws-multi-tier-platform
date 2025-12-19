# AWS Account Security Baseline (v1)

This document describes the initial security baseline applied to a new AWS account
before deploying any production-like infrastructure.

**Goal:** Reduce account-level risk, establish auditability, and prevent 
accidental or malicious misuse while operating within AWS Free Tier constraints.

---
## Index

- [Initial Risk Assessment](#initial)
- [Hardening Actions Taken](#hardening)
- [Baseline Metrics](#metrics)
- [Production Considerations](#prod)
- [Outcome](#outcome)

---
<a name="initial"></a>
## Initial Risk Assessment

A newly created AWS account presents several immediate risks if left unconfigured:

- Root account has unrestricted permissions and is a high-value target
- No audit trail exists by default to track API or console activity
- Credentials may be created without MFA enforcement
- Billing abuse or unexpected charges may go unnoticed
- Actions taken in any region may not be centrally visible

Before deploying infrastructure, these risks were addressed at the account level.

---
<a name="hardening"></a>
## Hardening Actions Taken

### Root Account Protection
- Enabled MFA on the root account
- Root account is not used for daily operations

**Rationale:**  
The root account has ultimate control over the AWS account. Any compromise would
result in full account takeover, so its usage is restricted to emergency scenarios
only.

---

### IAM Administrative User
- Created a dedicated IAM admin user
- Attached AdministratorAccess and Billing permissions
- Enabled MFA for the admin user

**Rationale:**  
This separates daily administrative tasks from the root account and establishes the
first step toward least-privilege access. MFA reduces the risk of credential
compromise.

---

### CloudTrail (All Regions)
- Enabled CloudTrail across all regions
- Logs all management and API activity

**Rationale:**  
CloudTrail provides auditability and supports detection of unauthorized access,
privilege escalation attempts, and suspicious API usage across the account.

---

### Billing Budget & Alerts
- Configured a monthly AWS Budget aligned with Free Tier limits
- Enabled default budget alerts

**Rationale:**  
This helps detect abnormal usage early and prevents accidental or malicious cost
overruns during experimentation.

---
<a name="metrics"></a>
## Baseline Metrics

| Metric | Before | After |
|------|--------|-------|
| Long-lived credentials | 1 (root) | 2 (root + admin IAM user) |
| MFA enabled | None | Root + Admin user |
| Audit coverage | None | Full account (all regions) |
| Human users with admin access | 0 | 1 |
| Regions monitored | 0 | All |
| Cost visibility | None | Monthly budget + alerts |

---
<a name="prod"></a>
## Production Considerations (Not Implemented)

In a real production environment, additional controls would be evaluated:

- Use AWS IAM Identity Center (SSO) instead of long-lived IAM users
- Enforce MFA and permission boundaries via SCPs
- Enable GuardDuty for threat detection
- Define log retention policies and centralized log storage
- Separate billing access into a dedicated finance role

These controls were intentionally not implemented at this stage to keep the
environment simple and Free Tier–compatible.

---
<a name="outcome"></a>
## Outcome

With this baseline in place, the AWS account now has:
- Reduced risk of root account misuse
- Basic least-privilege separation
- Full audit visibility
- Cost awareness before infrastructure deployment

This baseline serves as the foundation for all subsequent cloud infrastructure
projects in this repository.
