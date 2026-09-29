# Assignment - Kubernetes Pods, ReplicaSets & Deployments

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Pod lifecycle states.** Apply and inspect manifests for Running, Pending, Succeeded, Failed, CrashLoopBackOff, ImagePullBackOff, probes (readiness, liveness, startup), init containers, multi-container pods, and graceful termination, plus watch a short-lived `hello.yaml` Pod's transient states live via `kubectl get pods -w`.

**ReplicaSet management.** Deploy `yatri-backend-rs.yaml`, verify 3/3 pods, test scaling (up to 5, down to 1, back to 3), and prove self-healing by manually deleting a Pod and watching the controller replace it.

**Deployments and rolling updates.** Deploy `deployment-v1.yaml`, scale replicas, update with `deployment-v2.yaml`, and monitor the rolling rollout strategy (`maxSurge`/`maxUnavailable`) live.

**Troubleshooting.** Reproduce a selector/template label mismatch error, then fix and reapply successfully; reproduce a broken-image rollout stuck in `ImagePullBackOff` with a healthy v1 already running underneath, verify the old Pods survive untouched, then recover with `kubectl rollout undo`.

**Resource requests and limits.** Test and verify CPU throttling and memory OOMKill (`exit code 137`) under resource limits.

**Theoretical writeup.** The 4 ports, labels vs. selectors, the 4 deployment strategies, `maxSurge`/`maxUnavailable` math, and requests vs. limits with GB vs. GiB.

## 2. Notes

Ingress, ConfigMaps, and Secrets are not part of this assignment. That is the 8 September session, covered in [module 11](../11-kubernetes-ingress-configmaps-secrets/README.md). An earlier version of this module was filed under that session's title, because the transcript I had been given for that date turned out to be Pod-lifecycle content, so the folder is now named for what it actually contains.

Blue-Green, Canary, and Recreate deployment strategies are covered here only as theory (Task 7). The actual hands-on execution for those three lives in [extra-deployment-strategies](../extra-deployment-strategies/README.md), which sits outside the numbered 20-module sequence. StatefulSet hands-on deployment is likewise covered only conceptually here, with the real deployment in [extra-kubernetes-workloads-rollback-and-dns](../extra-kubernetes-workloads-rollback-and-dns/README.md), also outside the numbered sequence.

## 3. My completion checklist

- [x] Task 1: all 12 pod-lifecycle files applied, watched, described, and logged individually, including confirming that `kubectl logs` fails on a Pod stuck in Pending
- [x] Task 1: `hello.yaml` watched live via `kubectl get pods -w` through `Pending -> ContainerCreating -> Running -> Completed`, not just checked at the end state
- [x] Task 2: `yatri-backend-rs` ReplicaSet deployed, confirmed 3/3, scaled to 5 -> 1 -> back to 3, with self-healing proved by deleting a running Pod and watching the controller create a replacement
- [x] Task 3: `deployment-v1.yaml` applied, `kubectl get all` shows Pod + ReplicaSet + Deployment + Service together, scaled to 5 replicas
- [x] Task 4: `deployment-v2.yaml` applied over the running v1, rolling update observed live via `kubectl get pods -w`, image tag confirmed to flip from `nginx:1.25-alpine` to `nginx:1.27-alpine`
- [x] Task 5: `selector-mismatch.yaml` API-server rejection reproduced and fixed, `broken-image.yaml` `ImagePullBackOff` reproduced, and the full v1/v2 recovery drill completed with `kubectl rollout undo`
- [x] Task 6: CPU throttling and memory OOMKill (`exit code 137`) both reproduced with `polinux/stress` and confirmed via cgroup stats and `kubectl describe pod`
- [x] Task 7: theoretical writeup covering the 4 ports, labels vs. selectors, the 4 deployment strategies, `maxSurge`/`maxUnavailable` math, and requests vs. limits with GB vs. GiB units
