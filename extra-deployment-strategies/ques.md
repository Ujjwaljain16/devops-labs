# Assignment - Deployment Strategies: Blue-Green, Canary & Recreate

**Source:** "DevOps Assignment Season 2" consolidated doc, Lecture 10, Tasks 11-13. These three were flagged as a gap during a full repo audit against that doc. [Module 09](../09-kubernetes-pods-replicasets-deployments/README.md)'s Task 7 theory write-up already explains all four deployment strategies conceptually (RollingUpdate, Recreate, Blue-Green, Canary), but only RollingUpdate had actual hands-on execution anywhere in the repo. This module is the hands-on half for the other three.

## 1. What's required

- **Blue-Green:** deploy two complete, independent 3-replica environments (Blue v1, Green v2) side by side, route live traffic to Blue via a Service selector, cut traffic to Green with a single selector change, verify the switch is instant (no mixed-version window), and test rollback by flipping the selector back.
- **Canary:** deploy a 9-replica stable baseline and a 1-replica canary release under the *same* Service (10:1 pod ratio), verify the roughly 10% traffic split with a real request loop, shift the ratio to 30% by scaling, then roll back by scaling canary to 0.
- **Recreate:** deploy a 3-replica app with `strategy.type: Recreate`, trigger an update while a continuous request loop is running, and capture the real downtime window where 0 pods exist between v1 termination and v2 creation.

## 2. Notes

NodePort and external access were deliberately left out of these Services; I used `ClusterIP` with either `kubectl port-forward` or an in-cluster test Pod instead, since the actual external-access mechanics, including the Minikube Docker-driver NodePort gotcha, are their own separate topic covered in the Services module. I also did not build custom application images for each version; instead I used `nginx:alpine` with a per-version `ConfigMap`-mounted `index.html`, since the point of these labs is the deployment mechanics rather than the app itself.

## 3. My completion checklist

- [x] Blue and Green deployed simultaneously (3 replicas each), confirmed both healthy via `--show-labels`
- [x] Routed to Blue first, verified via curl (`BLUE ENVIRONMENT`)
- [x] Cut over to Green with one `kubectl apply` on the Service, verified `kubectl get endpoints` and curl both flipped to Green (`GREEN ENVIRONMENT`) instantly
- [x] Instant rollback tested: flipped the selector back to Blue, curl confirmed
- [x] Cleaned up the inactive deployment after testing
- [x] Canary: 9 stable and 1 canary pod deployed under one Service, confirmed the actual pod count split via labels
- [x] Ran a 20-request loop from inside the cluster, not via `kubectl port-forward`, which only forwards to one fixed Pod and does not actually load-balance (see README for why that mattered), and got a real approximately 10% canary hit rate
- [x] Scaled canary to 3 and stable to 7 (30%), re-ran the loop, got a real approximately 30% canary hit rate
- [x] Rolled back by scaling canary to 0, confirmed 100% traffic returned to stable
- [x] Recreate: deployed v1, ran a continuous curl loop, applied v2, captured the actual v1 to outage to v2 sequence live in the loop's own output
- [x] Checked `kubectl rollout history` and executed `kubectl rollout undo`, confirmed it went back to v1 (and re-triggered the same Recreate downtime pattern on the way back)
