# Gaps: what's left across the whole repo

Consolidated view of everything still open, across all 20 modules. Per-module `gaps.md` files (currently just [12-kubernetes-storage-hpa-probes/gaps.md](12-kubernetes-storage-hpa-probes/gaps.md)) hold module-specific detail; this file is the project-wide summary.

**Status: 20/20 modules built.** Modules 01-19 are complete, genuinely executed, and pushed. Module 20 is built as a standalone repository, with open items listed below. What's left:

---

## Module 20: built as a standalone repository, the doc's list is covered

The capstone is [Ujjwaljain16/campusslot](https://github.com/Ujjwaljain16/campusslot), a standalone public repository, with a pointer and an item-by-item checklist in [20-final-devops-project](20-final-devops-project/ques.md). It includes a real VPC and EKS cluster that I applied to the AWS account and destroyed about 45 minutes later, and a final check of `ap-south-1` found nothing left. The AWS credit balance still showed the full 120 USD right after the destroy, because billing data lags, and the real cost (estimated at about 10 US cents) is still to be confirmed in the billing console.

**The doc's Session 21 list is covered.** When I compared the capstone with it, I found five gaps (a ConfigMap, a Python dependency scan, log collection, a GitOps workflow and three README sections) and closed all of them. The checklist is in [20-final-devops-project/ques.md](20-final-devops-project/ques.md).

**Security note, still open:** the AWS secret access key currently in use was pasted directly into chat twice during troubleshooting (once for the first, non-working key, once for the working second one). Now that module 20 is finished, that key should be rotated in IAM (deactivate it, create a fresh one if it is still needed, update `~/.aws/credentials`) regardless of whether anything went wrong, since a credential that has been typed into a chat log should not stay active indefinitely. The same applies to real personal phone numbers that appeared in one of module 01's screenshots; those were redacted before committing. Separately, the 12-digit AWS account number appears in plain text in four files of this public repository (modules 17 and 18). It is an identifier and not a credential, but the owner may prefer to mask it.

---

## Module 12: two open items

See [12-kubernetes-storage-hpa-probes/gaps.md](12-kubernetes-storage-hpa-probes/gaps.md) for full detail. Short version:
1. **Task 3 Mini Project**: the tracking doc's Session 13 tab gives no brief at all, just "complete the mini project provided for Session 13" with nothing attached. Needs whatever handout the instructor shared live.
2. **Dedicated Probes coverage**: the session is titled "...HPA & Probes" but the doc's actual task list never breaks out a Probes task. Needs confirmation on whether module 09's existing liveness/readiness demos count as sufficient, or whether this session wants its own dedicated hands-on Probes work.

---

## Everything else

No other open items. Modules 01-11, 13, 14, 15, 16, 17, 18 are complete with no outstanding questions; see each module's own `ques.md` completion checklist for what was verified.
