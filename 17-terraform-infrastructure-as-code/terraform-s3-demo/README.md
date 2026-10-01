# Terraform S3 Demo

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

A Terraform project that creates a real AWS S3 bucket, with versioning enabled and public access fully blocked, following the exact workflow the doc asks for: `init`, `fmt`, `validate`, `plan`, `apply`, `show`, `output`, and `destroy`.

## Project structure

```
terraform-s3-demo/
├── provider.tf       # AWS provider, region from a variable
├── variables.tf      # aws_region, bucket_name, environment
├── main.tf           # the S3 bucket, versioning, and public access block
├── outputs.tf        # bucket_name, bucket_arn, bucket_region
├── terraform.tfvars  # real values for this run
└── README.md
```

## `terraform init`

```bash
terraform init
```
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above.

Terraform has been successfully initialized!
```

## `terraform fmt` and `terraform validate`

```bash
terraform fmt
terraform validate
```
```
Success! The configuration is valid.
```

`fmt` produced no output, which means it found nothing to reformat; I wrote the files already correctly formatted.

## `terraform plan`

Rather than apply blindly, I saved the plan to a file first so the exact reviewed actions are what actually gets applied:

```bash
terraform plan -out=tfplan
```
```
Terraform will perform the following actions:

  # aws_s3_bucket.demo will be created
  + resource "aws_s3_bucket" "demo" {
      + arn    = (known after apply)
      + bucket = "ujjwal-jain-24bcs10173-devops-labs-s3-demo"
      ...
    }

  # aws_s3_bucket_public_access_block.demo will be created
  + resource "aws_s3_bucket_public_access_block" "demo" {
      + block_public_acls       = true
      + block_public_policy     = true
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_versioning.demo will be created
  + resource "aws_s3_bucket_versioning" "demo" {
      + versioning_configuration {
          + status = "Enabled"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Saved the plan to: tfplan
```

## `terraform apply`

```bash
terraform apply tfplan
```
```
aws_s3_bucket.demo: Creating...
aws_s3_bucket.demo: Creation complete after 7s [id=ujjwal-jain-24bcs10173-devops-labs-s3-demo]
aws_s3_bucket_public_access_block.demo: Creating...
aws_s3_bucket_versioning.demo: Creating...
aws_s3_bucket_public_access_block.demo: Creation complete after 1s [id=ujjwal-jain-24bcs10173-devops-labs-s3-demo]
aws_s3_bucket_versioning.demo: Creation complete after 4s [id=ujjwal-jain-24bcs10173-devops-labs-s3-demo]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::ujjwal-jain-24bcs10173-devops-labs-s3-demo"
bucket_name = "ujjwal-jain-24bcs10173-devops-labs-s3-demo"
bucket_region = "ap-south-1"
```

This is a real bucket in a real AWS account, account `189393508581`, region `ap-south-1` (Mumbai).

## `terraform show`

```bash
terraform show
```
```
# aws_s3_bucket.demo:
resource "aws_s3_bucket" "demo" {
    arn                         = "arn:aws:s3:::ujjwal-jain-24bcs10173-devops-labs-s3-demo"
    bucket                      = "ujjwal-jain-24bcs10173-devops-labs-s3-demo"
    bucket_domain_name          = "ujjwal-jain-24bcs10173-devops-labs-s3-demo.s3.amazonaws.com"
    bucket_regional_domain_name = "ujjwal-jain-24bcs10173-devops-labs-s3-demo.s3.ap-south-1.amazonaws.com"
    hosted_zone_id              = "Z11RGJOFQNVJUP"
    region                      = "ap-south-1"
    tags                        = {
        "Environment" = "learning"
        "ManagedBy"   = "terraform"
        "Name"        = "ujjwal-jain-24bcs10173-devops-labs-s3-demo"
        "Student"     = "Ujjwal Jain"
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

# aws_s3_bucket_public_access_block.demo:
resource "aws_s3_bucket_public_access_block" "demo" {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# aws_s3_bucket_versioning.demo:
resource "aws_s3_bucket_versioning" "demo" {
    versioning_configuration {
        status = "Enabled"
    }
}
```

AWS applies server-side encryption (`AES256`) to the bucket by default, even though I never declared it in `main.tf`; this is AWS's own current default for new buckets, which `terraform show` picked up as real state rather than something I configured.

## `terraform output`

```bash
terraform output
```
```
bucket_arn = "arn:aws:s3:::ujjwal-jain-24bcs10173-devops-labs-s3-demo"
bucket_name = "ujjwal-jain-24bcs10173-devops-labs-s3-demo"
bucket_region = "ap-south-1"
```

## Independent verification

I did not just trust Terraform's own state file; I checked the bucket actually exists using the AWS CLI directly, a completely separate tool reading live AWS state:

```bash
aws s3 ls
```
```
2026-10-01 07:31:31 ujjwal-jain-24bcs10173-devops-labs-s3-demo
```

## `terraform destroy`

Done last, after Task 2's AWS research was written up, so the bucket stayed available a little longer to inspect. Same reviewed-plan pattern as the create step, this time with `-destroy`:

```bash
terraform plan -destroy -out=tfplan-destroy
```
```
Terraform will perform the following actions:

  # aws_s3_bucket.demo will be destroyed
  # aws_s3_bucket_public_access_block.demo will be destroyed
  # aws_s3_bucket_versioning.demo will be destroyed

Plan: 0 to add, 0 to change, 3 to destroy.

Saved the plan to: tfplan-destroy
```

```bash
terraform apply tfplan-destroy
```
```
aws_s3_bucket_public_access_block.demo: Destroying...
aws_s3_bucket_versioning.demo: Destroying...
aws_s3_bucket_public_access_block.demo: Destruction complete after 4s
aws_s3_bucket_versioning.demo: Destruction complete after 5s
aws_s3_bucket.demo: Destroying...
aws_s3_bucket.demo: Destruction complete after 0s

Apply complete! Resources: 0 added, 0 changed, 3 destroyed.
```

## Final independent verification

Same principle as after `apply`: checked with the AWS CLI directly rather than trusting Terraform's own account of what happened.

```bash
aws s3 ls
aws s3api head-bucket --bucket ujjwal-jain-24bcs10173-devops-labs-s3-demo
```
```
(aws s3 ls now returns nothing; the bucket is gone)

An error occurred (404) when calling the HeadBucket operation: Not Found
```

A real 404 from AWS, not an assumption. The complete lifecycle, create, verify it exists, destroy, verify it is really gone, all happened against a real AWS account, not a simulation.

I later ran an independent sanity check from my own terminal, well after the destroy above:

```
$ aws s3 ls
$
```

No output: the bucket does not exist, confirming the earlier automated destroy and verification. The doc's Session 18 tab does not list screenshots as a required deliverable for this module, only the documented workflow above, so no screenshot is included here.
