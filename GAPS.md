# Gaps — what's left across the whole repo

Consolidated view of everything still open, across all 20 modules. Per-module `gaps.md` files (currently just [12-kubernetes-storage-hpa-probes/gaps.md](12-kubernetes-storage-hpa-probes/gaps.md)) hold module-specific detail; this file is the project-wide summary.

**Status: 17/20 modules done.** Modules 01-16 and 19 are complete, genuinely executed, and pushed. What's left:

---

## Modules 17, 18, 20 — blocked on AWS credentials

**17 (Terraform & Infrastructure as Code)** and **18 (Cloud & Terraform in Action)** both explicitly require provisioning real AWS infrastructure via Terraform (S3 bucket, then a fuller VPC-based setup). **20 (Final DevOps Project)** is the capstone tying every module together, and its deliverable list also explicitly requires a `terraform/` folder and "Use Terraform to provision the required cloud infrastructure" — checked the doc directly to confirm this isn't optional or skippable the way module 19 turned out to be AWS-independent.

None of these three can start until there's a working AWS credential.

**Current state (2026-09-29):**
- AWS CLI v2.37.5 is already installed locally (`~/bin/aws` in WSL, user-local install, no sudo needed) — ready to go the moment credentials work.
- An AWS account was created, but its first access key (`AKIAUNUOAS4L2ZIAA2EA`) fails with `InvalidClientTokenId` — AWS doesn't recognize that key ID at all, meaning it likely never actually got created (a click didn't register) or was deleted/deactivated somewhere along the way.

**Needed to unblock:** a fresh IAM access key that actually authenticates. Steps (from the IAM console, under the user created for this — e.g. `terraform-devops-labs`):
1. Security credentials tab → check whether `AKIAUNUOAS4L2ZIAA2EA` is even listed. If not, that confirms it never existed.
2. Delete any stale/broken key shown there.
3. Create a new access key (choose "Command Line Interface (CLI)" as the use case) and copy **both** the Access Key ID and Secret Access Key from that same page before navigating away.
4. Run `aws configure` in WSL with the fresh pair (or hand them over and it'll be done from here).
5. I'll verify with a read-only `aws sts get-caller-identity` before touching Terraform at all.

**Security note:** the first key's secret was pasted directly into chat during troubleshooting. Once a working key is in place and 17/18/20 are done, that first key should be deleted/rotated in IAM regardless of whether it ever worked — a credential that's been typed into a chat log shouldn't stay active.

---

## Module 12 — two open items

See [12-kubernetes-storage-hpa-probes/gaps.md](12-kubernetes-storage-hpa-probes/gaps.md) for full detail. Short version:
1. **Task 3 Mini Project** — the tracking doc's Session 13 tab gives no brief at all, just "complete the mini project provided for Session 13" with nothing attached. Needs whatever handout the instructor shared live.
2. **Dedicated Probes coverage** — the session is titled "...HPA & Probes" but the doc's actual task list never breaks out a Probes task. Needs confirmation on whether module 09's existing liveness/readiness demos count as sufficient, or whether this session wants its own dedicated hands-on Probes work.

---

## Everything else

No other open items. Modules 01-11, 13, 14, 15, 16, 19 are complete with no outstanding questions — see each module's own `ques.md` completion checklist for what was verified.
