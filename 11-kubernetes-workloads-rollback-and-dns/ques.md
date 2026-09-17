# Assignment - Kubernetes Workloads, Rollback & DNS
---

## 1. What's actually required

- Workload comparison: analyze differences between StatefulSet, DaemonSet, and Deployment regarding pod identity, ordinals, scaling order, and storage (cross-referenced against [core-objects.md](https://github.com/Nency-Ravaliya/Kubernetes/blob/main/core-objects.md))
- Live DaemonSet verification: deploy a DaemonSet manifest (`daemonset-demo/daemonset.yaml`) to verify node-level pod placement
- Controller semantics: explain ReplicaSet vs. Deployment and the cascading ownership hierarchy
- Deployment revisions and rollback: build and apply 4 sequential Deployment revisions (`v1.yaml` to `v4.yaml`) with `kubernetes.io/change-cause` annotations, then execute a direct rollback from revision 4 to revision 1 (`kubectl rollout undo deployment/demo-app --to-revision=1`)
- CoreDNS and FQDN verification: inspect `/etc/resolv.conf` search domains inside a test pod (`curl-test-pod`), verify DNS resolution with `nslookup` for short and fully qualified domain names, and validate connectivity via HTTP request

## 2. Explicitly NOT part of this assignment

- Advanced Services suite reading (ClusterIP, NodePort, LoadBalancer, ExternalName, Headless from [session-11-kubernetes-services](https://github.com/Nency-Ravaliya/devops-heros/tree/main/session-11-kubernetes-services)) - reserved for dedicated networking labs

## 3. My completion checklist

- [x] Compared StatefulSet, DaemonSet, and Deployment architecture and ordering guarantees (cross-referencing `core-objects.md`)
- [x] Deployed and verified a live DaemonSet (`node-agent-demo`) on the cluster
- [x] Documented ReplicaSet vs. Deployment controller semantics and ownership chain
- [x] Built and sequentially applied 4 Deployment revisions (nginx 1.24 -> 1.25 -> 1.26 -> 1.27) with change annotations
- [x] Executed direct rollback from revision 4 to revision 1 via `--to-revision=1` and confirmed revision history
- [x] Verified `/etc/resolv.conf` DNS search domains and CoreDNS resolution
- [x] Tested short-name and FQDN resolution via `nslookup` and confirmed HTTP connectivity with `wget`
