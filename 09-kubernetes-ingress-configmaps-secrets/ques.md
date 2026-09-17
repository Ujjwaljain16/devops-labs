# Assignment - Kubernetes Ingress, ConfigMaps & Secrets
---

## 1. What's actually required

- Pod lifecycle states: apply and inspect manifests for Running, Pending, Succeeded, Failed, CrashLoopBackOff, ImagePullBackOff, probes (readiness, liveness, startup), init containers, multi-container pods, and graceful termination - plus watching a short-lived `hello.yaml` Pod's transient states live via `kubectl get pods -w`
- ReplicaSet management: deploy `yatri-backend-rs.yaml`, verify 3/3 pods, test scaling (scale up to 5, down to 1, back to 3), and prove self-healing by manually deleting a Pod and watching the controller replace it
- Deployments and rolling updates: deploy `deployment-v1.yaml`, scale replicas, update with `deployment-v2.yaml`, and monitor rolling rollout strategy (`maxSurge` / `maxUnavailable`) live
- Troubleshooting scenarios, diagnosis *and* recovery: reproduce selector/template label mismatch errors then fix and re-apply successfully; reproduce a broken-image rollout stuck in `ImagePullBackOff` (with a healthy v1 already running underneath), verify the old Pods survive untouched, then recover with `kubectl rollout undo`
- Resource requests and limits: test and verify CPU throttling and memory OOMKill (`exit code 137`) under resource limits
- Theoretical writeup: the 4 ports, labels vs. selectors, the 4 deployment strategies, `maxSurge`/`maxUnavailable` math, and requests vs. limits with GB vs. GiB

## 2. Explicitly NOT part of this assignment

- Ingress, ConfigMaps, and Secrets (not covered in this session despite the official title)
- Blue-Green, Canary, and Recreate deployment strategies as hands-on labs - covered here only as theory (Task 7); the actual hands-on execution for these three lives in a separate module since they're substantial enough to deserve one
- StatefulSet hands-on deployment - covered conceptually in [module 11](../11-kubernetes-workloads-rollback-and-dns/README.md), actual deployment lives there too

## 3. My completion checklist

- [x] All 12 pod-lifecycle files applied, watched, described, and logged individually
- [x] Confirmed `kubectl logs` fails on a Pod stuck in Pending (no container exists yet to have logs)
- [x] `hello.yaml` - watched `Pending -> ContainerCreating -> Running -> Completed` live via `kubectl get pods -w`, not just checked the end state
- [x] `yatri-backend-rs` ReplicaSet deployed, confirmed 3/3, scaled to 5 -> 1 -> back to 3
- [x] Self-healing proved: manually deleted a running RS Pod, confirmed the controller created a brand-new one (different name) within seconds, deleted the standalone RS after testing
- [x] `deployment-v1.yaml` applied, `kubectl get all` shows Pod + ReplicaSet + Deployment + Service together, scaled to 5 replicas
- [x] `deployment-v2.yaml` applied over the running v1, rolling update observed live via `kubectl get pods -w`
- [x] Confirmed the live image tag actually flipped from `nginx:1.25-alpine` to `nginx:1.27-alpine` post-rollout
- [x] `selector-mismatch.yaml` - reproduced the exact API-server rejection, then fixed the label and re-applied successfully (`selector-mismatch-fixed.yaml`)
- [x] `broken-image.yaml` - reproduced `ImagePullBackOff` on a real stuck rollout, then cleaned it up
- [x] `broken-image-v1.yaml` / `broken-image-v2.yaml` - the full recovery drill: healthy v1 deployed first, broken v2 surged on top, confirmed old Pods stayed `Running` untouched while only the new Pod failed, then recovered with `kubectl rollout undo` and confirmed the image landed back on the known-good tag
- [x] CPU limit exceeded - reproduced real throttling via `polinux/stress` capped at `200m` against 2 CPU-hungry workers, confirmed via `/sys/fs/cgroup/cpu.stat`
- [x] Memory limit exceeded - reproduced a real `OOMKilled` (`exit code 137`) via `polinux/stress` requesting 300M against a `100Mi` limit, confirmed via `kubectl describe pod`
- [x] Theoretical writeup covering the 4 ports, labels vs. selectors, the 4 deployment strategies, `maxSurge`/`maxUnavailable` math, and requests vs. limits with GB vs. GiB units
