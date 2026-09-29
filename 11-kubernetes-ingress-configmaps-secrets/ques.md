# Assignment - Kubernetes Ingress, ConfigMaps & Secrets

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Ingress, ConfigMaps & Secrets (8 Sep, 4:30 PM per the LMS schedule)
**Source:** Lecture 12 section of the "DevOps Assignment Season 2" task list (14 tasks)

**Why this module exists:** the transcript I originally received for the 8 Sep slot turned out to be Pod-lifecycle, ReplicaSet, and Deployment content, so that work was first filed under this session's title by mistake. It now lives in [module 09](../09-kubernetes-pods-replicasets-deployments/README.md) under its correct name (Kubernetes Pods, ReplicaSets & Deployments), and this module is the real ConfigMaps, Secrets, and Ingress work, built straight from the task list.

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**ConfigMaps & Secrets (Tasks 1-6).** Create and inspect a declarative ConfigMap, patch it live to show that a running Pod does not pick up the change until restarted, create an Opaque Secret and decode it, demonstrate the base64 trailing-newline gotcha, write up enterprise secret management, and deploy a backend that consumes both the ConfigMap (via `envFrom`) and the Secret (via `secretKeyRef`).

**Ingress (Tasks 7-14).** Write up Ingress resource versus Ingress controller, enable the NGINX Ingress Controller addon, map a hostname through `/etc/hosts`, and demonstrate path-based routing, host-based routing, hybrid host-and-path routing, TLS termination, and an end-to-end automation script with cleanup.

**Deliverables:** ConfigMap and Secret demo, Ingress demo (path-based, host-based, hybrid, TLS), enterprise secrets writeup, Ingress resource vs. controller writeup, screenshots, README.md.

## 2. Notes

I ran this module on the same Minikube cluster (WSL2 Ubuntu, Docker driver) as the other Kubernetes modules. Two things about that setup shaped how I tested the Ingress parts. On the Docker driver, the node IP is not reachable from WSL, so all Ingress traffic in this module goes through `kubectl port-forward` on the controller rather than a direct NodePort request. Editing `/etc/hosts` also requires `sudo` and a password, which I could not type into a scripted shell, so I ran that one step by hand in an interactive terminal; where a hostname mattered elsewhere, I used `curl --resolve host:port:127.0.0.1`, which does the same job for a single request without touching the hosts file.

This module deliberately does not cover a real cloud load balancer in front of the Ingress controller, since Minikube has none, or storage, HPA, and probes, which belong to the next session (10 Sep).

## 3. My completion checklist

- [x] ConfigMap created and inspected; live patch shown to have no effect on a running Pod until `rollout restart`
- [x] Secret created and decoded; base64 confirmed as encoding, not encryption; trailing-newline gotcha reproduced with `xxd`
- [x] Enterprise secret-management writeup, backed by a real `kubectl get crds` check
- [x] Backend deployed consuming the ConfigMap via `envFrom` and the Secret via `secretKeyRef`, verified with `kubectl exec ... env`
- [x] Ingress resource vs. controller writeup, backed by a real `kubectl api-resources` check
- [x] NGINX Ingress Controller addon enabled and verified with `kubectl wait`
- [x] Path-based, host-based, and hybrid routing all demonstrated and verified against the expected backend for each request
- [x] TLS termination demonstrated with a self-signed certificate and a verified HTTPS handshake
- [x] `run-demo.sh` built the whole stack and `cleanup.sh` removed it, including a caught and reproduced timing race on the freshly created Ingress
- [x] Screenshots captured for every task above
