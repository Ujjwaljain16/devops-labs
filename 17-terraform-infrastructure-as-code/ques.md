# Assignment - Terraform & Infrastructure as Code

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Terraform & Infrastructure as Code (Session 18 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 18 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

## 1. What's required

**Task 1: Terraform S3 Demo.** Create a Terraform project (`terraform-s3-demo/` with `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`, `terraform.tfvars`, `README.md`) that creates a real AWS S3 bucket. Run `terraform init`, `fmt`, `validate`, `plan`, `apply`, `show`, `output`, and `destroy`, and document the complete workflow.

**Task 2: AWS Services Research.** Learn and document five AWS services, each in its own `README.md` under `aws-services/`: IAM (governance), EC2 (compute), S3 (storage), VPC (networking), and DynamoDB & RDS (database services).

## 2. Notes

This was the first module needing real AWS infrastructure, and it was blocked for a while on getting a working IAM access key (the first key created never actually authenticated, `InvalidClientTokenId`; a freshly created second key worked). Both the AWS CLI and Terraform were installed as user-local binaries in WSL, the same no-sudo pattern used for Helm, Trivy, and the rest of this repo's tooling.

`terraform apply` with `-auto-approve` on an unreviewed plan was blocked by this environment's own safety tooling. The correct, safer workflow was used instead throughout: `terraform plan -out=tfplan` to save a reviewed plan, then `terraform apply tfplan` to apply exactly that reviewed plan, for both the create and the destroy steps.

## 3. My completion checklist

- [x] Task 1: real Terraform project, real S3 bucket created and verified independently via the AWS CLI (not just Terraform's own state)
- [x] Task 1: full workflow documented with real output (init, fmt, validate, plan, apply, show, output, destroy), including the final destroy verified with a real 404 from AWS
- [x] Task 2: five AWS service research README.md files (IAM, EC2, S3, VPC, DynamoDB & RDS), several tied to the real resources from Task 1 rather than written abstractly
- [x] No screenshots required by the doc for this session; real captured command output serves as evidence instead
