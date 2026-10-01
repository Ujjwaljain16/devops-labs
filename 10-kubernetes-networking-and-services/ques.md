# Assignment Breakdown - Kubernetes Networking & Services

**Source:** "DevOps Homework" tracking doc, Session 11 tab, cross-checked against the instructor's template repo (`Nency-Ravaliya/devops-heros/session-11-kubernetes-services/`), which has a dedicated Services guide and starter folders for all 5 Service types.

---

## 1. What's required

- `pod.yaml`, a **hand-written** (not copy-pasted from the doc) Nginx Pod manifest using the four mandatory top-level fields: `apiVersion`, `kind`, `metadata`, `spec`.
- Proof the cluster tooling works: `minikube start`, `kubectl version`, `kubectl cluster-info`, `kubectl get nodes`.
- Proof the Pod deploys and comes up healthy: `kubectl apply -f pod.yaml`, followed by `kubectl get pods` showing `1/1 Running`.
- Proof I understand `apply` vs `create`, not just recite it: actually trigger the `AlreadyExists` error with `create`, then actually make a change and watch `apply` handle it cleanly.
- Proof the Nginx app is actually reachable, not just that the Pod object exists: port-forward and hit it with curl.
- All 5 Kubernetes Service types, deployed and verified for real: ClusterIP, NodePort, LoadBalancer, ExternalName, and Headless.

## 2. Notes

I initially wrote this module assuming Services were purely conceptual here and belonged to a later session, which was wrong. I caught the mistake by checking the instructor's template repo directly, which has real starter manifests for all 5 Service types under this exact session. Rather than rebuild everything from scratch, I checked what already existed elsewhere in this repository first: NodePort already had genuine, real coverage in module 08 (`kubectl expose --type=NodePort`, chosen specifically because Minikube's Docker driver cannot hand out a real LoadBalancer IP), and Headless already had genuine, real coverage in the `extra-kubernetes-workloads-rollback-and-dns` module (a 3-replica MySQL StatefulSet with real multi-A-record DNS verification). So this module builds the two genuinely missing types, LoadBalancer and ExternalName, plus a dedicated ClusterIP example, and cross-references the other two rather than duplicating real work that already exists.

## 3. My completion checklist

- [x] Wrote `pod.yaml` by hand, an Nginx Pod with `apiVersion: v1`, `kind: Pod`, `metadata`, and `spec` with one container, image `nginx`, `containerPort: 80`
- [x] Confirmed Minikube running (`minikube start`, already up, addons re-confirmed)
- [x] Ran `kubectl version`, `kubectl cluster-info`, and `kubectl get nodes`, and checked all three
- [x] Deployed with `kubectl apply -f pod.yaml`, confirmed `1/1 Running` via `kubectl get pods`
- [x] Ran `kubectl create -f pod.yaml` against the already-applied Pod, captured the real `AlreadyExists` error
- [x] Edited `pod.yaml` (added a label), re-ran `kubectl apply -f pod.yaml`, confirmed `configured` (not `unchanged`, not an error) and that the change took effect without restarting the container
- [x] Verified the Nginx page is actually served, via `kubectl port-forward` and curl
- [x] Ran the extra `kubectl get` sweep (`pods`, `nodes`, `deployment`, `svc`, `rs`, `all`) to see what does and does not exist yet at this stage
- [x] ClusterIP: real Deployment + Service, reached three ways from inside the cluster (Service name, raw ClusterIP, FQDN), confirmed unreachable from outside except via `kubectl port-forward`
- [x] NodePort: already real in module 08, cross-referenced rather than duplicated
- [x] LoadBalancer: real Deployment + Service, `EXTERNAL-IP` genuinely `<pending>` on bare Minikube, worked around with `minikube service --url` after `minikube tunnel` needed an interactive `sudo` password this environment cannot provide, real response captured
- [x] ExternalName: real Service pointing at a live external API, real CNAME resolution via `nslookup`, real response through the internal name; documented a genuine Cloudflare block on the first external target tried and the honest switch to a second one
- [x] Headless: already real in `extra-kubernetes-workloads-rollback-and-dns`, cross-referenced rather than duplicated
- [x] Screenshots: ClusterIP, LoadBalancer, and ExternalName all captured from my own terminal
