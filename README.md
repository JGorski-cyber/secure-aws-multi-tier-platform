# 🔐 AWS Cloud Security Foundations — Account Hardening, Auditability, and IAM Monitoring

<a name="project-overview"></a>
## Project Overview

This independent portfolio project addresses a common early-stage cloud security problem:

- **New AWS accounts often lack basic safeguards, auditability, and investigation capabilities**, leaving identity misuse and misconfiguration difficult to detect.

The project assumes a **single AWS account in a pre-production state**, prior to deploying any application workloads. Within this environment, it establishes **preventive, detective, and operational security controls** focused on identity protection, centralized logging, and incident investigation.

Using AWS-native services and Infrastructure as Code (Terraform), the project incrementally builds a **controlled and observable cloud foundation**, suitable for monitoring administrative activity, investigating security events, and operating safely under cost and tooling constraints.

---
## Index

- [Project Overview](#project-overview)
- [Scope & Constraints](#scope)
- [Threat & Risk Model](#threat)
- [High-Level Architecture & Diagram](#architecture)
- [Project Modules](#modules)
  - [Module 1 — Account Baseline & **Hardening**](#module-1)
  - [Module 2 — Centralized Audit Logging with **CloudTrail**](#module-2)
  - [Module 3 — IAM Activity Investigation with **Athena**](#module-3)
  - [Module 4 — IAM Security Monitoring with **CloudWatch**](#module-4)
  - [Module 5 — Security Operator **IAM Role**](#module-5)
- [Validation & Testing Approach](#validation)
- [Design Tradeoffs](#design)
- [Skills Demonstrated](#skills)
- [Repository Structure](#repository)
- [Conclusion](#conclusion)
---
<a name="scope"></a>
## 🎯 Scope & Constraints

This project was intentionally designed with the following constraints:

- AWS Free Tier–only environment
- Single AWS account
- No enterprise SIEM or third-party security tooling
- Low-volume / synthetic activity data
- AWS-native services only

These constraints reflect common limitations in early-stage or small-scale cloud environments and required deliberate design tradeoffs around **monitoring scope, signal quality, and cost control**.

---
<a name="threat"></a>
## 🚨 Threat & Risk Model

This project focuses on mitigating common risks present in newly created or lightly governed AWS accounts, including:

- Root and IAM credential misuse, whether accidental or malicious
- Lack of centralized auditability for management activities
- Undetected identity lifecycle changes (user creation, deletion, or misuse)
- Delayed visibility into abnormal authentication behavior
- Uncontrolled cost exposure in unmanaged environments

The implemented controls prioritize **early detection and investigation** of these risks over exhaustive security coverage.

---
<a name="architecture"></a>
## 🏗️ High-Level Architecture & Diagram

At a high level, the project establishes the following security architecture:

- Account baseline hardening for **identity and cost control**
- CloudTrail enabled for centralized **management audit logging**
- CloudWatch Logs and Alarms for **IAM-focused security monitoring**
- Athena for **investigative and forensic analysis** of CloudTrail log data
- Read-only Security Operator role for **safe investigation without administrative access**
- Infrastructure and security resources are provisioned primarily using Terraform.

**Full Architecture Diagram & Service Wiring:**

(INSERT PROJECT ARCHITECTURE DIAGRAM)

**Early-stage architecture diagrams can be found under:**
- `/docs/diagrams`

---
<a name="modules"></a>
## 🗂️ Project Modules

<a name="module-1"></a>
### 🛡️ Module 1 — Account Baseline & Hardening

**Objective:**

- Establish a secure, auditable AWS account baseline before deploying any infrastructure, within Free Tier constraints.

**Controls:**
- Root account protected with MFA and restricted to emergency use
- Dedicated IAM administrative user created with MFA enabled
- CloudTrail enabled across all regions for audit logging of management events
- AWS Budget configured with cost alerts aligned to Free Tier limits

**Outcome:**
- Reduced risk of root account compromise and accidental misuse
- Full account-wide audit visibility and basic cost governance in place

**📝 Full Documentation, Screenshots, and Results:**
- `/docs/account-baseline.md`

--- 
<a name="module-2"></a>
### 🌐 Module 2 — Centralized Audit Logging with CloudTrail

**Objective:**

- Ensure all AWS management-plane and API activity is centrally logged and auditable across regions from day one.

**Controls:**
- CloudTrail enabled for all regions to capture API activity regardless of region usage
- Management events logged only, focusing on control-plane actions where IAM abuse occurs
- Dedicated S3 bucket used exclusively for CloudTrail log storage
- S3 bucket hardened with public access blocked and restricted write permissions

**Outcome:**
- Account-wide visibility into administrative and IAM-related activity
- Tamper-resistant audit trail suitable for security investigations and forensics

---
<a name="module-3"></a>
### 🔎 Module 3 — IAM Activity Investigation with Athena

**Objective:**
- Validate that IAM lifecycle events, policy changes, and security-relevant activity can be reliably detected using CloudTrail logs queried through Amazon Athena.

**Controls:**
- CloudTrail management event logs used as the authoritative audit source
- Amazon Athena configured to query CloudTrail logs stored in S3
- SQL queries developed to detect IAM lifecycle, abnormal authentication behavior, and privilege-related events

**Outcome:**
- Successfully detected IAM user creation/deletion and policy attachment/detachment generated via AWS CLI
- Confirmed visibility into console vs API usage, root account activity, denied actions, and privilege escalation indicators

**📝 Full Documentation, Screenshots, and Results:**
- `/docs/athena-investigation-report.md`
- `/docs/athena-query-outputs` (Output Screenshots)
- `/athena-queries.sql`

---
<a name="module-4"></a>
### 📢 Module 4 — IAM Security Monitoring with CloudWatch

**Objective:**
- Detect high-risk IAM activity using CloudWatch filters and alarms with minimal noise and clear operational value.

**Controls:**
- CloudTrail management events streamed into CloudWatch Logs
- CloudWatch Logs metric filters for security-relevant IAM activity
- CloudWatch alarms for root account usage, IAM lifecycle changes, and console login failures

**Outcome:**
- Validated real-time detection of IAM user creation/deletion and root account usage
- Implemented threshold-based alerting for repeated console login failures with documented limitations

**📝 Full Documentation, Screenshots, and Results:**
- `/docs/cloudwatch-alarms.md`
- `/docs/cloudwatch-alarm-tests` (Alarm Screenshots)

--- 
<a name="module-5"></a>
### 🕵🏻‍♂️ Module 5 — Security Operator IAM Role (Read-Only Investigation Access)

**Objective:**
- Validate a dedicated read-only IAM role that enables security investigations without allowing modification of logging, IAM, or audit-critical resources.

**Controls:**
- IAM role with AssumeRole (STS) access model
- Read-only permissions for CloudTrail logs (S3), CloudWatch Logs, and Athena
- Scoped S3 write permissions limited to Athena query results bucket only

**Validation Performed:**
- Assumed role via AWS CLI and executed Athena queries against CloudTrail data
- Listed and downloaded CloudTrail logs from S3
- Queried CloudWatch Logs for management events
- Performed negative tests against IAM modification, log deletion, and CloudTrail control actions

**Outcome:**
- Confirmed investigative access across Athena, S3, and CloudWatch Logs
- Verified enforcement of least privilege with all destructive or administrative actions denied

**📝 Full Documentation, Screenshots, and Results:**
- `/docs/security-operator-role-validation.md`
- `/docs/security-operator-access-tests` (Test Screenshots)

---
<a name="validation"></a>
## 🧪 Validation & Testing Approach

All controls in this project were validated through hands-on testing to confirm both
**expected access** and **expected failure**.

Validation methods included:
- Manual AWS CLI testing using scoped IAM identities and assumed roles
- Event generation to trigger CloudTrail, Athena queries, and CloudWatch alarms
- Negative testing to confirm denial of destructive or privileged actions

Testing focused on verifying:
- Audit visibility (logs are generated, accessible, and queryable)
- Least privilege enforcement (unauthorized actions are denied)
- Monitoring accuracy (alarms trigger and recover as expected)

Detailed validation steps and evidence are documented within each module’s supporting files.

---
<a name="design"></a>
## ⚖️ Design Tradeoffs

This project intentionally prioritizes **clarity, security fundamentals, and Free Tier compatibility**
over enterprise-scale complexity.

Key tradeoffs include:

- **Single AWS account vs multi-account architecture**  
  A single account was used to reduce operational overhead and focus on core security controls.
  In production, a multi-account strategy with centralized logging would be preferred.

- **Management-plane visibility over data-plane depth**  
  The project focuses on IAM, CloudTrail, and control-plane activity, as these are common
  attack paths in real-world AWS breaches.

- **AWS-native tooling over third-party SIEMs**  
  CloudTrail, Athena, and CloudWatch were used to demonstrate foundational detection and
  investigation capabilities without external dependencies.

- **IAM users over SSO**  
  IAM users were used to maintain simplicity and Free Tier compatibility.
  In production, IAM Identity Center (SSO) would be recommended.

---
<a name="skills"></a>
## 💡 Skills Demonstrated

- **AWS Identity & Access Management (IAM)**
  - Least-privilege role design & validation
  - IAM user lifecycle monitoring
  - Root account risk mitigation

- **Cloud Security Monitoring & Detection**
  - CloudTrail configuration and log analysis
  - CloudWatch metric filters and alarms
  - High-signal IAM activity detection

- **Security Investigation & Forensics**
  - Athena-based log querying
  - IAM activity reconstruction
  - Privilege escalation indicator analysis

- **Infrastructure as Code (Terraform)**
  - Reproducible security infrastructure
  - Explicit resource configuration
  - Controlled defaults and safeguards

- **Operational Security Thinking**
  - Threat-aware design decisions
  - Validation through positive and negative testing
  - Clear separation of duties and access

---
<a name="repository"></a>
## 🛠️ Repository Structure (WIP)

```text
.
├── terraform/                 # Infrastructure as Code (AWS resources)
│   ├── iam.tf
│   ├── cloudtrail.tf
│   ├── cloudwatch.tf
│   └── cloudwatch_metrics_alarms.tf
│
├── docs/                      # Module documentation and validation reports
│   ├── account-baseline.md
│   ├── cloudtrail-logging.md
│   ├── athena-investigation.md
│   ├── cloudwatch-monitoring.md
│   └── security-operator-role.md
│
├── athena-queries.sql         # Investigation queries
└── README.md                  # Project overview and module summaries
```

---
<a name="conclusion"></a>
## ✅ Conclusion

This project demonstrates a practical approach to securing and monitoring an AWS account
using native services, validated controls, and deliberate design tradeoffs.

It is intended as a foundation for further cloud security work and as evidence of
hands-on AWS security engineering capability.
