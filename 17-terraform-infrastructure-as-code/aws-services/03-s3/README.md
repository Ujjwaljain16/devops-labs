# AWS S3 (Simple Storage Service)

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

## What is S3?

S3 is AWS's object storage service: durable, effectively unlimited storage for arbitrary files (objects), accessed over HTTP(S) rather than mounted as a filesystem. [Task 1](../../terraform-s3-demo/README.md) of this module created a real bucket through Terraform, so every concept below is demonstrated against that actual bucket rather than described abstractly.

## Buckets

A bucket is a top-level, globally uniquely named container for objects. "Globally unique" means unique across every AWS account on the planet, not just this one, which is why the real bucket created for this module is named `ujjwal-jain-24bcs10173-devops-labs-s3-demo` rather than something generic like `demo-bucket`, a name that was almost certainly already taken by someone else's account.

## Objects

An object is a file plus metadata, stored under a key (its path-like name within the bucket). S3 itself has no real directory structure; keys that look like `folder/file.txt` are a UI and convention, not an actual nested filesystem. Objects can range from 0 bytes to 5TB each.

## Storage classes

S3 offers multiple storage classes trading cost against retrieval speed and frequency:

| Class | Use case |
|---|---|
| S3 Standard | Frequently accessed data, millisecond retrieval |
| S3 Standard-IA (Infrequent Access) | Accessed less often, still millisecond retrieval, lower storage cost, a retrieval fee |
| S3 One Zone-IA | Same as Standard-IA, but stored in only one Availability Zone, cheaper and less durable |
| S3 Glacier Instant/Flexible/Deep Archive | Archival; retrieval ranges from milliseconds to many hours, at steadily lower storage cost |

The bucket created in this module uses the default S3 Standard class; no lifecycle rule was added to transition objects to a cheaper class, since it holds no real long-lived data.

## Versioning

With versioning enabled, every `PUT` to the same key creates a new version instead of overwriting the previous one, and a `DELETE` adds a delete marker rather than erasing history. This was turned on for real in Task 1's `aws_s3_bucket_versioning` resource and confirmed afterward with `terraform show`:

```
resource "aws_s3_bucket_versioning" "demo" {
    versioning_configuration {
        status = "Enabled"
    }
}
```

## Lifecycle policies

A lifecycle rule automatically transitions objects to a cheaper storage class, or deletes them, after a set number of days. A typical real rule looks like: move to Standard-IA after 30 days, Glacier after 90, delete after 365. None was added here since the bucket is short-lived for this module's own demo, but this is the mechanism production buckets use to control storage cost over time without any application-level cleanup code.

## Encryption

Two layers exist, and AWS applied one automatically without being asked:

- **Server-side encryption at rest**, `AES256`, which `terraform show` reported as present on the bucket even though `main.tf` never declared it, because AWS now enables SSE-S3 by default on every new bucket.
- **Encryption in transit**, via HTTPS, enforced by using the S3 API at all rather than an unencrypted protocol; this is a client-side choice (the AWS CLI and Terraform's AWS provider both use HTTPS by default) rather than a bucket setting.

## Bucket policies

A bucket policy is a resource-level, JSON-based access policy attached directly to the bucket, distinct from an IAM identity policy attached to a user or role. This module's bucket has no bucket policy at all; instead, `aws_s3_bucket_public_access_block` blocks every form of public access outright:

```
resource "aws_s3_bucket_public_access_block" "demo" {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}
```

## Common use cases

- Static website hosting, serving HTML/CSS/JS directly from a bucket.
- A Terraform remote state backend, the standard place teams store `terraform.tfstate` so it is shared and locked across a team rather than kept on one person's laptop (not used in this module, where state stays local, but the natural next step for this exact project).
- Application file storage: user uploads, generated reports, backups, logs.
- A target for CI/CD build artifacts, conceptually the same role GHCR plays for Docker images in [module 16](../../16-cicd-devsecops/README.md), just for arbitrary files instead of container images.
