# Assignment Breakdown — Kubernetes Pods, ReplicaSets & Deployments

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Pods, ReplicaSets & Deployments
**Date:** 3 September 2026
**Source:** Reconstructed from the instructor's end-of-session transcript (not a written assignment sheet). No deadline, marks, submission portal, or screenshot requirement was explicitly stated in the transcript — I'm documenting this the way I'd want a real lab record to look regardless.

This file exists to separate "what was actually assigned" from "what was just discussed in class," since the two get blurred easily in a lecture transcript. The answers/execution proof for everything below live in [README.md](README.md).

---

## 1. What's actually required (core homework)

| # | Task | Why it's required |
|---|------|--------------------|
| 1 | Read the official Kubernetes architecture docs (`kubernetes.io/docs/concepts/architecture/`) and cross-check against class notes | Instructor was explicit: official docs > any third-party tutorial, and the goal is to *sync* understanding, not just skim names |
| 2 | Install Minikube locally | Explicitly assigned as homework — needed before the next hands-on session |
| 3 | Verify Minikube actually works — run `minikube start`, then `minikube status` | Instructor's own validation method; "Hello Minikube" doc is the reference path for this |

Implicitly bundled into #2/#3: **kubectl CLI** has to be installed/available too, since the instructor uses it for cluster inspection right after Minikube is up.

## 2. What's optional / get-ahead material

| Task | Status |
|------|--------|
| Walk through "Deploy an application" from the Kubernetes Basics tutorial (`kubernetes.io/docs/tutorials/kubernetes-basics/`) using the Hello Minikube example | Explicitly called out as optional — a way to preview next session's hands-on Pod/ReplicaSet/Deployment work, not a deliverable |

I did this anyway (see README, Task 4) since it's the cleanest way to actually *prove* Minikube works end-to-end, not just that the binary runs — and because seeing a real Pod → ReplicaSet → Deployment stack come up ties directly back into the lecture title.

## 3. Concepts I need to be able to explain after Task 1 (not separate deliverables, but the actual point of the reading)

- **Cluster** — the overall environment (control plane + worker nodes).
- **Control plane / master node** — etcd, API server, scheduler, controller manager (+ cloud-controller-manager as the cloud-only piece).
- **Worker node** — kubelet, kube-proxy (optional depending on CNI), and the container runtime (CRI — containerd by default).
- **Node** — analogous to a single server/EC2 instance running workloads.
- **Pod** — the smallest deployable unit; wraps one or more containers.
- **Container** — where the actual application process runs.
- **The flow**: everything talks to everything else *through* the API server (front-door/security-guard analogy) — scheduler, controllers, kubelet, and etcd don't talk to each other directly.

## 4. Explicitly NOT part of this assignment

Per the transcript, these are either recap or "coming next session" — not to be confused with today's deliverables:

- Docker / Docker Compose recap (already covered in modules [05](../05-docker-fundamentals/README.md)–[07](../07-docker-networking-and-volumes/README.md) of this repo)
- Writing actual Pod / ReplicaSet / Deployment YAML manifests — instructor said this is next session's hands-on work
- DaemonSets, deeper networking, scaling/rollback scenarios — future topics

## 5. My completion checklist

- [x] Read the official Kubernetes architecture docs and cross-checked against the lecture's component breakdown
- [x] Can identify control-plane components: etcd, API server, scheduler, controller manager
- [x] Can identify worker-node components: kubelet, kube-proxy, CRI (containerd)
- [x] Understand the Pod → Node → Cluster relationship and the "everything goes through the API server" flow
- [x] kubectl installed and working
- [x] Minikube installed
- [x] `minikube start` works
- [x] `minikube status` confirms the local cluster is healthy
- [x] Looked at the Hello Minikube docs
- [x] (Optional) Ran the Hello Minikube "Deploy an application" example end-to-end, including hitting the running service with curl
