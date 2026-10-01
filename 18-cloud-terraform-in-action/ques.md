# Assignment - Cloud & Terraform in Action

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Cloud & Terraform in Action (Session 19 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 19 tab

The commands, real output, screenshot, and architecture diagram for everything below are in [README.md](README.md).

## 1. What's required

Build an end-to-end cloud infrastructure project using Terraform, demonstrating: providers, variables, resources, outputs, dependencies, real AWS infrastructure, Terraform state, and `plan`/`apply`/`destroy`.

Suggested architecture: VPC -> Subnet -> Security Group -> EC2 -> S3.

Deliverables: Terraform project, real AWS resources, architecture diagram, screenshots, Terraform commands, README.md.

## 2. Notes

This reused the same AWS account and IAM credential already set up in [module 17](../17-terraform-infrastructure-as-code/). The one real surprise here: my first plan used `t2.micro` for the EC2 instance, the classic "free tier" default, and `terraform apply` genuinely failed because this account's actual free-tier-eligible instance types are `t3.micro` and a few others, not `t2.micro`. Fixed by querying `aws ec2 describe-instance-types --filters Name=free-tier-eligible,Values=true` and switching to `t3.micro`.

Given the real cost exposure of creating EC2/VPC resources, even at free tier, I followed a strict create-verify-destroy-verify discipline within the same session: nothing was left running between turns. The security group only opens SSH and HTTP to my own IP, never to the whole internet, and no NAT Gateway or Elastic IP was created since those are the usual source of an unexpected AWS bill.

## 3. My completion checklist

- [x] Real Terraform project: providers, variables, resources (VPC, subnet, IGW, route table, security group, EC2, S3), outputs, and dependencies between them (e.g. the EC2 instance depends on the subnet and the security group)
- [x] Full workflow documented with real output: `init`, `fmt`, `validate`, `plan`, `apply`, `destroy`, including a genuine mid-workflow failure (wrong free-tier instance type) and its fix
- [x] Real AWS resources created and independently verified via the AWS CLI, including a real `curl` against the EC2 instance's nginx server, not just Terraform's own reported state
- [x] Architecture diagram: [architecture-diagram.svg](architecture-diagram.svg)
- [x] Screenshot from my own terminal, not just agent-captured output: [screenshots/01-verification.png](screenshots/01-verification.png)
- [x] Everything destroyed and independently verified gone (terminated instance, 404 on the bucket, `InvalidVpcID.NotFound` on the VPC) in the same session it was created
