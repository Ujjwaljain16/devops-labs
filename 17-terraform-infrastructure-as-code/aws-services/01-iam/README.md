# AWS IAM (Identity and Access Management)

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

## What is IAM?

IAM is the service that controls who can do what inside an AWS account. It governs authentication (proving who you are) and authorization (what you are allowed to do), for both humans and the services AWS itself runs on a person's behalf. Nothing in AWS, not even the account owner acting through the root login, bypasses IAM for anything beyond account-level billing and a handful of root-only actions.

## Users

An IAM user is an identity for a single person or application, with its own credentials (a console password, an access key pair, or both). I created a real one for this module, `terraform-devops-labs`, specifically so Terraform would never need to run as the account's root user. Its ARN is `arn:aws:iam::189393508581:user/terraform-devops-labs`, confirmed with:

```bash
aws sts get-caller-identity
```
```
{
    "UserId": "AIDASYGF3TDSWLP5EFVDX",
    "Account": "189393508581",
    "Arn": "arn:aws:iam::189393508581:user/terraform-devops-labs"
}
```

## Groups

A group is a named collection of users that a policy can be attached to once, instead of attaching the same policy to every user individually. Adding or removing a user from a group instantly changes their effective permissions, which is the main operational reason to use groups once an account has more than a couple of users: permission changes become a membership change, not a per-user policy edit repeated many times.

## Roles

A role is also an identity with policies attached, but unlike a user it has no permanent credentials of its own. It is meant to be assumed, temporarily, by something else: another AWS service (an EC2 instance, a Lambda function), a user in the same account, or a user in a completely different AWS account. AWS issues short-lived temporary credentials for the duration the role is assumed. This is how EC2 instances are supposed to reach S3 or DynamoDB in production: an instance role, not a long-lived access key baked into the instance.

## Policies

A policy is a JSON document that states what is allowed or denied, on which resources, under which conditions. AWS ships many ready-made ones (`AdministratorAccess`, `AmazonS3ReadOnlyAccess`); custom ones can be written for anything not covered. A minimal policy statement looks like:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::ujjwal-jain-24bcs10173-devops-labs-s3-demo/*"
    }
  ]
}
```

## Permissions

Permissions are the sum of every policy attached to an identity, directly or through a group or role, combined with any resource-level policy (such as an S3 bucket policy) that also names that identity. An explicit `Deny` anywhere in that combination always wins over an `Allow` anywhere else; AWS evaluates every applicable statement, not just the first match.

## Least privilege

The principle that an identity should hold exactly the permissions it needs to do its job, no more. For this module, `AdministratorAccess` was attached to `terraform-devops-labs` for simplicity on a personal learning account; in a real production setup, the honest least-privilege version would instead be scoped to only the specific S3 (and later EC2/VPC) actions Terraform in this repo actually calls, nothing broader.

## IAM best practices

- Never use the root account for everyday work; create an IAM user (or role) for that.
- Enable MFA, especially on root and on any identity with broad permissions.
- Prefer roles with temporary credentials over long-lived access keys wherever the workload allows it (EC2, Lambda, CI/CD via OIDC).
- Rotate access keys that do exist, and delete any that are no longer in use. This module is a real example of why: a secret access key for this account was pasted into a chat conversation twice during troubleshooting, so it needs rotating once Terraform work here is finished, regardless of whether that particular key is still the active one.
- Grant permissions through groups and roles rather than attaching policies to individual users one at a time.

## Common use cases

- A CI/CD pipeline assuming a role to push a Docker image to a registry or deploy to Kubernetes, the same shape as [module 16](../../../16-cicd-devsecops/README.md)'s `GITHUB_TOKEN`-based push to GHCR, just on AWS instead of GitHub Container Registry.
- An EC2 instance assuming a role to read from S3 or write to DynamoDB, without any access key stored on the instance itself.
- A separate IAM user per tool or person (like `terraform-devops-labs` here) so that revoking one credential never affects anything else using the account.
