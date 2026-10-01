# Terraform & Infrastructure as Code

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for the exact task breakdown. This module has two parts, each documented in its own folder:

- **[terraform-s3-demo/](terraform-s3-demo/README.md)**, Task 1: a real Terraform project that creates, inspects, and destroys a real AWS S3 bucket, with the full `init`/`fmt`/`validate`/`plan`/`apply`/`show`/`output`/`destroy` workflow genuinely executed.
- **[aws-services/](aws-services/)**, Task 2: five research write-ups, one per service (IAM, EC2, S3, VPC, DynamoDB & RDS), several of which reference the real resources created in Task 1 rather than describing AWS in the abstract.

This was the first module in this repo needing real AWS infrastructure, and it stayed blocked for a while on getting a working credential: the first IAM access key created never actually authenticated (`InvalidClientTokenId`), which turned out to mean it had never really been created in the first place; a freshly generated second key worked immediately. Both the AWS CLI and Terraform were installed as user-local binaries in WSL, no `sudo` needed, the same pattern already used for Helm, Trivy, and the rest of this repo's tooling.

## Screenshots

*(pending; see the checkpoint note)*
