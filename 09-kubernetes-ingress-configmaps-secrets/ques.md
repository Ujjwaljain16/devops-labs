# Assignment Breakdown — Kubernetes Ingress, ConfigMaps & Secrets

**Course:** SST DevOps & Cloud [SWE]
**Lecture (official session title):** Kubernetes Ingress, ConfigMaps & Secrets
**Actual lecture content:** Pod lifecycle, ReplicaSets, Deployments, rolling updates, resource requests/limits
**Date:** 8 September 2026
**Instructor:** Ritesh Prajapati
**Source:** Instructor's session transcript, converted into a checklist.

**Title mismatch, explained once and for all:** the uploaded transcript file was titled "Kubernetes Ingress, ConfigMaps & Secrets" — that's also this module's official session title for the date, so the README and this file are labeled that way for now, to match the syllabus/session record. But the actual transcript *content* is entirely about Pod lifecycle, ReplicaSets, Deployments, rolling updates, and resource limits. Ingress, ConfigMaps, and Secrets are **not** substantiated by the transcript text and are **not** treated as done or as homework here — this module's real content is everything below, labeled honestly as what it actually is.

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
| 6 | Resource requests/limits — built my own CPU-throttle and memory-OOMKill demos since the instructor mentioned an assessment exists but didn't hand out its actual questions in the transcript | [resource-limits/](resource-limits/) |

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

- Ingress, ConfigMaps, Secrets — not covered in this session's actual content despite the session's official title
- Blue-Green / Canary / geo-based deployment strategies — mentioned conceptually only, no hands-on example given
- The instructor's own specific assessment/problem-solving questions on resource limits — never handed out in this transcript, so I couldn't reproduce *those exact* questions; instead I built and ran my own CPU-throttle and memory-OOMKill scenarios to demonstrate the same underlying mechanisms for real (see Task 6 in README.md)

## 6. My completion checklist

- [x] All 12 pod-lifecycle files applied, watched, described, and logged individually
- [x] Confirmed `kubectl logs` fails (as expected) on a Pod stuck in Pending — no container exists yet to have logs
- [x] `yatri-backend-rs` ReplicaSet deployed, confirmed 3/3, scaled to 5 → 1 → back to 3, deleted after testing
- [x] `deployment-v1.yaml` applied, `kubectl get all` shows Pod + ReplicaSet + Deployment + Service together, scaled to 5 replicas
- [x] `deployment-v2.yaml` applied over the running v1, rolling update observed live via `kubectl get pods -w`
- [x] Confirmed the live image tag actually flipped from `nginx:1.25-alpine` to `nginx:1.27-alpine` post-rollout
- [x] `selector-mismatch.yaml` — reproduced the exact API-server rejection for a selector/template-label mismatch
- [x] `broken-image.yaml` — reproduced `ImagePullBackOff` on a real stuck rollout, then cleaned it up
- [x] CPU limit exceeded — reproduced real throttling via `polinux/stress` capped at `200m` against 2 CPU-hungry workers, confirmed via `/sys/fs/cgroup/cpu.stat` (`nr_throttled 238` of `nr_periods 239`)
- [x] Memory limit exceeded — reproduced a real `OOMKilled` (`exit code 137`) via `polinux/stress` requesting 300M against a `100Mi` limit, confirmed via `kubectl describe pod`, restart count climbing (crash-loop)
