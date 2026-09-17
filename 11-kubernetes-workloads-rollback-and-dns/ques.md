# Assignment Breakdown — Kubernetes Workloads, Rollback & DNS

**Course:** SST DevOps & Cloud [SWE]
**Source:** Instructor's homework list for this session (five explicit items), cross-referenced against the running Minikube cluster and this repo's existing modules where the list pointed at them.

The execution/proof for everything below lives in [README.md](README.md).

---

## A note on two references in the original assignment that don't actually exist in this repo

Before diving in, two things the assignment text pointed at turned out not to be present anywhere in this repo, and I'm not going to pretend otherwise:

1. **"Session 10's `Kubernetes-main` repo's `core-objects.md`"** — no `Kubernetes-main` repo and no `core-objects.md` file exist anywhere in this working tree. I went straight to the official Kubernetes docs (`kubernetes.io/docs/concepts/workloads/controllers/statefulset/`) instead for Task 1's StatefulSet research.
2. **`session-11-kubernetes-services/dns-test/curl-test-pod.yaml`** — no folder named `session-11-kubernetes-services` exists here. This repo's own numbering has [`10-kubernetes-networking-and-services/`](../10-kubernetes-networking-and-services/) as the closest thematic match, and its own `ques.md` explicitly says Services/labels/selectors were "introduced conceptually as the next stage, explicitly not assigned" in that session — so a Services-focused `dns-test` folder genuinely doesn't exist yet anywhere in this repo. For Task 4 below I built my own `dns-test/curl-test-pod.yaml` from scratch, following the same filename the assignment described, so it's easy to tell what I actually did vs. what was assumed to already exist.

Everything else below was directly actionable and I did it for real against the live Minikube cluster from [module 08](../08-kubernetes-pods-replicasets-deployments/).

---

## 1. StatefulSet vs. DaemonSet vs. Deployment

**Status:** Explicitly flagged by the instructor as *not taught this session* — "it's not in your syllabus, but we'll add it... write down as one of your homework." The only hint given: a StatefulSet Pod "is created in a particular manner," left deliberately vague on purpose.

Since there was no `core-objects.md` to lean on (see note above), I answered this from the official Kubernetes docs directly, and backed the DaemonSet half with an actual `kubectl apply` on the live cluster rather than just quoting the docs. See README Task 1.

## 2. ReplicaSet vs. Deployment

**Status:** Not a knowledge gap — the instructor is asking me to be able to *articulate* something that was already covered in real depth in this repo's [module 09](../09-kubernetes-ingress-configmaps-secrets/README.md) (ReplicaSet create/scale, Deployment v1→v2 rolling update, watched live). I'm not re-deriving that whole exercise; I've written a concise, direct answer in the README that references back to the concrete evidence already sitting in module 09, plus the ownership chain visible in this module's own rollback demo (Task 3).

## 3. Build a 4-revision Deployment (V1 → V4) and roll back V4 → V1 directly

**Status:** Required, hands-on. Done against the live cluster:
- Four real Deployment manifests (`deployment/v1.yaml` through `v4.yaml`), each bumping the nginx image tag and carrying a `kubernetes.io/change-cause` annotation so `kubectl rollout history` shows a meaningful log.
- Applied sequentially, watched each `kubectl rollout status` actually complete.
- Rolled back straight from revision 4 to revision 1 in one command: `kubectl rollout undo deployment/demo-app --to-revision=1`.

## 4. Research + document FQDN and CoreDNS

**Status:** Required. The instructor called this "one of the most important parts of Kubernetes" and tied it directly to the next session's Service/ClusterIP hands-on. I wrote up what FQDN and CoreDNS actually are (from the official docs), then proved it hands-on rather than just describing it: a real `dns-test` pod, `cat /etc/resolv.conf` inside it, `nslookup` against both a short name and a full FQDN, and an actual `wget` HTTP request that only succeeds if DNS resolution *and* the Service's endpoint routing both work.

## 5. Read through the Services examples folder (ClusterIP, NodePort, LoadBalancer, ExternalName, Headless)

**Status:** Optional prep reading, not a deliverable — and, per the note at the top, the specific folder the assignment described doesn't exist in this repo yet under any name. [`10-kubernetes-networking-and-services/`](../10-kubernetes-networking-and-services/) is the closest thing that exists locally, and its own scope explicitly stops before Services are introduced. Nothing to read yet; flagging this so it isn't silently treated as done.

## 6. My completion checklist

- [x] Answered StatefulSet vs. DaemonSet vs. Deployment from official docs (no `core-objects.md` available), with a real DaemonSet demo on the live cluster
- [x] Answered ReplicaSet vs. Deployment clearly, building on module 09's existing evidence rather than repeating it
- [x] Built and applied 4 real Deployment revisions (nginx 1.24 → 1.25 → 1.26 → 1.27)
- [x] Rolled back directly from revision 4 to revision 1 with `--to-revision=1`, verified the image and rollout history afterward
- [x] Researched FQDN + CoreDNS from official docs
- [x] Proved DNS resolution + Service routing hands-on: `resolv.conf`, short-name and FQDN `nslookup`, and a working `wget` through the Service's DNS name
- [ ] Read the Services examples folder — not possible yet, doesn't exist in this repo (see note above)
