# Assignment - Kubernetes Workloads, Rollback & DNS

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Workload comparison.** I analyzed the differences between StatefulSet, DaemonSet, and Deployment with respect to pod identity, ordinals, scaling order, and storage, cross-referenced against [core-objects.md](https://github.com/Nency-Ravaliya/Kubernetes/blob/main/core-objects.md).

**Live workload verification.** Deploy a DaemonSet manifest (`daemonset-demo/daemonset.yaml`) to verify node-level pod placement. Deploy a headless Service plus a three-replica MySQL StatefulSet (`statefulset-demo/`) to verify ordinal naming, strictly sequential startup, PVC-per-ordinal binding, headless-service multi-A-record DNS, and identity invariance (deleting `mysql-0` and confirming it returns as `mysql-0`), contrasted directly against a Deployment Pod's random-hash replacement.

**Controller semantics.** Explain ReplicaSet versus Deployment and the cascading ownership hierarchy between them.

**Deployment revisions and rollback.** Build and apply four sequential Deployment revisions (`v1.yaml` through `v4.yaml`) with `kubernetes.io/change-cause` annotations, then execute a direct rollback from revision 4 to revision 1 with `kubectl rollout undo deployment/demo-app --to-revision=1`.

**CoreDNS and FQDN verification.** Inspect `/etc/resolv.conf` search domains inside a test pod (`curl-test-pod`), verify DNS resolution with `nslookup` for both short and fully qualified domain names, and validate connectivity with an HTTP request.

## 2. Notes

The advanced Services suite (ClusterIP, NodePort, LoadBalancer, ExternalName, and Headless, from [session-11-kubernetes-services](https://github.com/Nency-Ravaliya/devops-heros/tree/main/session-11-kubernetes-services)) is explicitly not part of this assignment. I am leaving that reading for the dedicated networking labs.

StatefulSet itself was not taught in this session; the instructor flagged it as homework research, with only the clue that a StatefulSet Pod "is created in a particular manner." Rather than stopping at the comparison table, I deployed both a DaemonSet and a three-replica MySQL StatefulSet myself to confirm what that ordering, storage, and identity behavior actually looks like on a real cluster, and I did the same for CoreDNS resolution and the deployment rollback rather than only describing them.

## 3. My completion checklist

- [x] Compared StatefulSet, DaemonSet, and Deployment architecture and ordering guarantees (cross-referencing `core-objects.md`)
- [x] Deployed and verified a live DaemonSet (`node-agent-demo`) on the cluster
- [x] Deployed and verified a live 3-replica MySQL StatefulSet: ordinal naming, sequential readiness-gated startup, PVC-per-ordinal, headless-service DNS with multiple A records, per-ordinal direct FQDN addressing, and identity invariance vs. a Deployment's random-hash replacement
- [x] Documented ReplicaSet vs. Deployment controller semantics and ownership chain
- [x] Built and sequentially applied 4 Deployment revisions (nginx 1.24 -> 1.25 -> 1.26 -> 1.27) with change annotations
- [x] Executed direct rollback from revision 4 to revision 1 via `--to-revision=1` and confirmed revision history
- [x] Verified `/etc/resolv.conf` DNS search domains and CoreDNS resolution
- [x] Tested short-name and FQDN resolution via `nslookup` and confirmed HTTP connectivity with `wget`
