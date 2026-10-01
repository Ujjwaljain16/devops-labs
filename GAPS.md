# Gaps: what's left across the whole repo

Consolidated view of everything still open, across all 20 modules. Per-module `gaps.md` files (currently just [12-kubernetes-storage-hpa-probes/gaps.md](12-kubernetes-storage-hpa-probes/gaps.md)) hold module-specific detail; this file is the project-wide summary.

**Status: 18/20 modules done.** Modules 01-17 and 19 are complete, genuinely executed, and pushed. What's left:

---

## Modules 18 and 20: blocked on nothing now except time, AWS itself is unblocked

AWS was the long-standing blocker here. It is resolved: a working IAM access key (`terraform-devops-labs` user, account `189393508581`) is configured in WSL, and module 17 proved the whole toolchain end to end with a real S3 bucket (created, verified via the AWS CLI, destroyed, verified gone with a real 404). Both the AWS CLI and Terraform are installed as user-local binaries, no sudo needed.

**18 (Cloud & Terraform in Action)** needs a fuller VPC-based infrastructure build using the same now-working credential. **20 (Final DevOps Project)** is the capstone tying every module together, and its deliverable list also requires a `terraform/` folder provisioning real cloud infrastructure. Neither has been started yet; both are now just a matter of building them the same way module 17 was built.

**Cost/safety rule for all remaining AWS work (18 and 20):** everything must stay strictly within the AWS free tier. Only `t2.micro`/`t3.micro` for any EC2 instance, S3, and plain VPC/subnets/route tables/Internet Gateway (all genuinely $0). No NAT Gateway (the most common source of a surprise bill, not free-tier covered). Every `terraform apply` is immediately followed by a `terraform destroy` once evidence is captured, the same create-verify-destroy-verify discipline already proven in module 17. Nothing is left running between sessions.

**Security note, still open:** the AWS secret access key currently in use was pasted directly into chat twice during troubleshooting (once for the first, non-working key, once for the working second one). Once 18 and 20 are done, that key should be rotated in IAM (deactivate it, create a fresh one, update `~/.aws/credentials`) regardless of whether anything went wrong, since a credential that has been typed into a chat log should not stay active indefinitely. The same applies to real personal phone numbers that appeared in one of module 01's screenshots; those were redacted before committing, but the key rotation is still outstanding.

---

## Module 12: two open items

See [12-kubernetes-storage-hpa-probes/gaps.md](12-kubernetes-storage-hpa-probes/gaps.md) for full detail. Short version:
1. **Task 3 Mini Project**: the tracking doc's Session 13 tab gives no brief at all, just "complete the mini project provided for Session 13" with nothing attached. Needs whatever handout the instructor shared live.
2. **Dedicated Probes coverage**: the session is titled "...HPA & Probes" but the doc's actual task list never breaks out a Probes task. Needs confirmation on whether module 09's existing liveness/readiness demos count as sufficient, or whether this session wants its own dedicated hands-on Probes work.

---

## Everything else

No other open items. Modules 01-11, 13, 14, 15, 16, 17, 19 are complete with no outstanding questions; see each module's own `ques.md` completion checklist for what was verified.
