# Assignment - Kubernetes Ingress, ConfigMaps & Secrets
---

## 1. What's actually required

- Pod lifecycle states: apply and inspect manifests for Running, Pending, Succeeded, Failed, CrashLoopBackOff, ImagePullBackOff, probes (readiness, liveness, startup), init containers, multi-container pods, and graceful termination
- ReplicaSet management: deploy `yatri-backend-rs.yaml`, verify 3/3 pods, and test scaling (scale up to 5, down to 1, back to 3)
- Deployments and rolling updates: deploy `deployment-v1.yaml`, scale replicas, update with `deployment-v2.yaml`, and monitor rolling rollout strategy (`maxSurge` / `maxUnavailable`) live
- Troubleshooting scenarios: reproduce and inspect selector/template label mismatch errors and broken image rollout failures (`ImagePullBackOff`)
- Resource requests and limits: test and verify CPU throttling and memory OOMKill (`exit code 137`) under resource limits

## 2. Explicitly NOT part of this assignment

- Ingress, ConfigMaps, and Secrets (not covered in this session despite the official title)
- Advanced deployment strategies (Blue-Green, Canary, geo-based deployments)

## 3. My completion checklist

- [x] All 12 pod-lifecycle files applied, watched, described, and logged individually
- [x] Confirmed `kubectl logs` fails on a Pod stuck in Pending (no container exists yet to have logs)
- [x] `yatri-backend-rs` ReplicaSet deployed, confirmed 3/3, scaled to 5 -> 1 -> back to 3, deleted after testing
- [x] `deployment-v1.yaml` applied, `kubectl get all` shows Pod + ReplicaSet + Deployment + Service together, scaled to 5 replicas
- [x] `deployment-v2.yaml` applied over the running v1, rolling update observed live via `kubectl get pods -w`
- [x] Confirmed the live image tag actually flipped from `nginx:1.25-alpine` to `nginx:1.27-alpine` post-rollout
- [x] `selector-mismatch.yaml` - reproduced the exact API-server rejection for a selector/template-label mismatch
- [x] `broken-image.yaml` - reproduced `ImagePullBackOff` on a real stuck rollout, then cleaned it up
- [x] CPU limit exceeded - reproduced real throttling via `polinux/stress` capped at `200m` against 2 CPU-hungry workers, confirmed via `/sys/fs/cgroup/cpu.stat`
- [x] Memory limit exceeded - reproduced a real `OOMKilled` (`exit code 137`) via `polinux/stress` requesting 300M against a `100Mi` limit, confirmed via `kubectl describe pod`
