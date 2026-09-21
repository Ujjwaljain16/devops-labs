# Assignment - Kubernetes Ingress, ConfigMaps & Secrets

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Ingress, ConfigMaps & Secrets (8 Sep, 4:30 PM per the LMS schedule)
**Source:** Lecture 12 section of the "DevOps Assignment Season 2" task list (14 tasks)

**Why this module exists:** the transcript I originally got for the 8 Sep slot turned out to be Pod-lifecycle / ReplicaSet / Deployment content, so that work was first filed under this session's title by mistake. It now lives in [module 09](../09-kubernetes-pods-replicasets-deployments/README.md) under its correct name (Kubernetes Pods, ReplicaSets & Deployments), and this module is the real ConfigMaps + Secrets + Ingress work, built straight from the task list.

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**ConfigMaps**
1. Create a declarative ConfigMap (`ENVIRONMENT`, `LOG_LEVEL`, `PORT`, `DEFAULT_CURRENCY`, `MAX_BOOKING_DAYS`), inspect it with `describe`, and read single keys with JSONPath
2. Patch a live ConfigMap, prove running Pods do **not** see the change, then load it with `kubectl rollout restart`

**Secrets**
3. Create an `Opaque` Secret for DB credentials, understand base64 is encoding not encryption, and decode values with JSONPath | `base64 --decode`
4. Show the trailing-newline gotcha: `echo` vs `echo -n` when base64-encoding (hex-dump both with `xxd`)
5. Write up why base64 Secrets in Git are an anti-pattern and how enterprises solve it (External Secrets Operator, Vault, AWS Secrets Manager / Azure Key Vault, CI/CD variable groups)
6. Deploy a backend that takes the whole ConfigMap via `envFrom` and the Secret key-by-key via `secretKeyRef`, and verify with `kubectl exec ... env`

**Ingress**
7. Write up Ingress *resource* vs Ingress *controller*
8. Enable the NGINX Ingress Controller addon on Minikube and verify it with `kubectl wait`
9. Map `yatri.local` to the cluster in `/etc/hosts` and confirm resolution
10. Path-based routing on one host: `/` -> frontend, `/api(/|$)(.*)` -> backend with `rewrite-target: /$2`
11. Host-based (virtual host) routing: `portal.campus.local` and `api.campus.local` behind one IP
12. Hybrid routing: host *and* path rules in one Ingress
13. TLS termination: `openssl` self-signed cert -> `kubernetes.io/tls` Secret -> `spec.tls` -> verify HTTPS on 443 with `curl -k --resolve`
14. End-to-end: `run-demo.sh` / `cleanup.sh`, multi-document YAML (Deployment + Service in one file), and a single `kubectl get` audit of the whole stack

## 2. Deliberately not part of this module

- A real cloud load balancer in front of the Ingress controller (Minikube has none - see the Docker-driver access note in the README)
- Storage, HPA and probes - that's the next session (10 Sep)

## 3. My completion checklist

- [x] ConfigMap created; `describe` shows all 5 keys; JSONPath returns `production` / `INFO`
- [x] Live patch to `staging`: running Pod still showed `production`, only new Pods after `rollout restart` showed `staging`; patch reverted afterwards
- [x] Secret created; `describe` shows masked byte lengths; JSONPath | `base64 --decode` returns `secretpassword` / `yatri_admin`
- [x] `xxd` proves plain `echo` adds a trailing `0a` byte and changes the base64 (`...QK` vs `...Q=`)
- [x] Enterprise secret-management writeup, plus a real `kubectl get crds` check (no secret-operator CRDs installed here)
- [x] Backend deployed with `envFrom` + `secretKeyRef`; `kubectl exec ... env` shows both
- [x] Ingress resource vs controller writeup, plus `kubectl api-resources` check
- [x] NGINX Ingress addon enabled; controller `1/1 Running`, `kubectl wait` condition met
- [x] Path-based routing on `yatri.local`: `/` -> frontend, `/api/...` -> backend with the prefix stripped (`/api/orders/42` reached the backend as `/orders/42`)
- [x] Host-based routing: `portal.campus.local` and `api.campus.local` on the same IP + port
- [x] Hybrid host + path routing in one Ingress, including confirming `api.campus.local/` correctly 404s
- [x] TLS: self-signed cert -> `kubernetes.io/tls` Secret -> `spec.tls`; handshake verified (TLS 1.3, my cert served, HTTP -> HTTPS 308 redirect)
- [x] `run-demo.sh` built the whole stack, one label-based `kubectl get` audited it, `cleanup.sh` removed it and the follow-up checks confirmed it was gone
- [x] `/etc/hosts` mapping (Task 9): `minikube ip` proved unreachable from WSL (Docker driver), so the hostnames map to `127.0.0.1` behind a port-forward; entry added by hand with `sudo`, `grep` confirms it, and the bare hostname now resolves (`308` from the TLS-enabled Ingress)
- [x] Caught and reproduced a real timing race: routes return 404 for ~3 seconds after an Ingress is created, then 200
