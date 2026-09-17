# Assignment Breakdown — Kubernetes Pod Lifecycle, ReplicaSets & Deployments

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Pod Lifecycle, ReplicaSets & Deployments
**Date:** 8 September 2026
**Source:** Instructor's session transcript, converted into a checklist. Note from the transcript itself: the uploaded file was titled "Kubernetes Ingress, ConfigMaps & Secrets," but the actual content is entirely about Pod lifecycle, ReplicaSets, Deployments and rolling updates — Ingress/ConfigMaps/Secrets aren't in here because they're just not in the transcript.

This file is "what was assigned," kept separate from "how I did it." The execution, real `kubectl` output, and screenshots for every item below live in [README.md](README.md).

---

## 1. The one explicit take-home item

The instructor's clearest direct instruction, given right after the Deployment v1 walkthrough: **run a v2 deployment as homework.** Everything else below (pod lifecycle states, ReplicaSet scaling, Deployment v1, the troubleshooting scenarios) is session practice that was demonstrated live for *some* of the cases — I went through the rest of it independently since the lab files and their structure are self-explanatory enough to extend without hand-holding.

## 2. What I actually worked through, task by task

| # | Task | Where |
|---|------|-------|
| 1 | All 12 files in `pod-lifecycle/`, applied in order with `kubectl apply -f`, watched with `kubectl get pods -w`, inspected with `kubectl describe pod` and `kubectl logs` for each — the ones covered live (Running, Pending, Succeeded, Failed, CrashLoopBackOff, image-pull failure) *and* the ones only implied by the lecture title (readiness, liveness, startup probes, init containers, multi-container, graceful termination) | [pod-lifecycle/](pod-lifecycle/) |
| 2 | `yatri-backend-rs` ReplicaSet — deploy, confirm 3 Pods, scale up to 5, down to 1, back to 3 | [replicaset/yatri-backend-rs.yaml](replicaset/yatri-backend-rs.yaml) |
| 3 | `deployment-v1.yaml` — deploy, confirm via `kubectl get all`, scale to 5 replicas | [deployments/deployment-v1.yaml](deployments/deployment-v1.yaml) |
| 4 | `deployment-v2.yaml` over the running v1 — watched the rolling update live via `kubectl get pods -w` | [deployments/deployment-v2.yaml](deployments/deployment-v2.yaml) |
| 5 | `troubleshooting/selector-mismatch.yaml` and `troubleshooting/broken-image.yaml` — deliberately broken files to see the actual errors | [troubleshooting/](troubleshooting/) |

## 3. Pod lifecycle states this covers (and why 12 files, not 7)

| State | File |
|---|---|
| Running | `01-running-pod.yaml` |
| Pending (unschedulable) | `02-pending-pod.yaml` |
| Succeeded / Completed | `03-succeeded-pod.yaml` |
| Failed | `04-failed-pod.yaml` |
| CrashLoopBackOff | `05-crashloopbackoff-pod.yaml` |
| Image pull failure | `06-image-pull-failure-pod.yaml` |
| Readiness probe (Running but not Ready) | `07-readiness-probe-pod.yaml` |
| Liveness probe (auto-restart on failed health check) | `08-liveness-probe-pod.yaml` |
| Startup probe (protects slow-starting apps from liveness) | `09-startup-probe-pod.yaml` |
| Init container (setup phase before the main container starts) | `10-init-container-pod.yaml` |
| Multi-container / sidecar | `11-multi-container-pod.yaml` |
| Graceful termination (`preStop` + `terminationGracePeriodSeconds`) | `12-graceful-termination-pod.yaml` |

The first 6 map to what the instructor demoed live. The last 6 (readiness, liveness, startup, init container, multi-container, graceful termination) are the ones the lecture title implies but didn't get walked through command-by-command in class — I wrote and ran these on my own to actually see the behavior instead of just reading about it.

## 4. Rolling update fields carried over from the lecture

`deployment-v2.yaml` sets `maxSurge: 1` / `maxUnavailable: 1` on 3 desired replicas — same numbers the instructor used to explain the strategy conceptually (up to 4 Pods can exist mid-rollout, at least 2 must stay available). Wanted to see the actual numbers play out live, not just take the explanation on faith.

## 5. Deliberately out of scope

Per the transcript, these are either recap or "next session," not today's deliverable:

- Ingress, ConfigMaps, Secrets — not covered in this session's actual content despite the misleading upload title
- Blue-Green / Canary / geo-based deployment strategies — mentioned conceptually only, no hands-on example given
- Resource requests/limits deep-dive assessment — instructor mentioned a separate assessment/problem-solving exercise exists for this, but didn't hand out its actual questions in this transcript

## 6. My completion checklist

- [x] All 12 pod-lifecycle files applied, watched, described, and logged individually
- [x] Confirmed `kubectl logs` fails (as expected) on a Pod stuck in Pending — no container exists yet to have logs
- [x] `yatri-backend-rs` ReplicaSet deployed, confirmed 3/3, scaled to 5 → 1 → back to 3, deleted after testing
- [x] `deployment-v1.yaml` applied, `kubectl get all` shows Pod + ReplicaSet + Deployment + Service together, scaled to 5 replicas
- [x] `deployment-v2.yaml` applied over the running v1, rolling update observed live via `kubectl get pods -w`
- [x] Confirmed the live image tag actually flipped from `nginx:1.25-alpine` to `nginx:1.27-alpine` post-rollout
- [x] `selector-mismatch.yaml` — reproduced the exact API-server rejection for a selector/template-label mismatch
- [x] `broken-image.yaml` — reproduced `ImagePullBackOff` on a real stuck rollout, then cleaned it up
