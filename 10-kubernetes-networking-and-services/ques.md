# Assignment Breakdown - Kubernetes Networking & Services

---



## 1. The actual deliverable

- `pod.yaml` - a **hand-written** (not copy-pasted from the doc) Nginx Pod manifest using the four mandatory top-level fields: `apiVersion`, `kind`, `metadata`, `spec`.
- Proof the cluster tooling works: `minikube start`, `kubectl version`, `kubectl cluster-info`, `kubectl get nodes`.
- Proof the Pod deploys and comes up healthy: `kubectl apply -f pod.yaml` → `kubectl get pods` → `1/1 Running`.
- Proof I understand `apply` vs `create`, not just recite it: actually trigger the `AlreadyExists` error with `create`, then actually make a change and watch `apply` handle it cleanly.
- Proof the Nginx app is actually reachable, not just "the Pod object exists": port-forward and hit it with `curl`.

## 2. Deliberately not part of this assignment

- `service.yaml`, Services, labels/selectors as a connection mechanism - introduced conceptually as the next stage, explicitly not required as a submission for this session

## 3. My completion checklist

- [x] Wrote `pod.yaml` by hand - Nginx Pod, `apiVersion: v1` / `kind: Pod` / `metadata` / `spec` with one container, image `nginx`, `containerPort: 80`
- [x] Confirmed Minikube running (`minikube start` - already up, addons re-confirmed)
- [x] `kubectl version`, `kubectl cluster-info`, `kubectl get nodes` all run and checked
- [x] Deployed with `kubectl apply -f pod.yaml`, confirmed `1/1 Running` via `kubectl get pods`
- [x] Ran `kubectl create -f pod.yaml` against the already-applied Pod, captured the real `AlreadyExists` error
- [x] Edited `pod.yaml` (added a label), re-ran `kubectl apply -f pod.yaml`, confirmed `configured` (not `unchanged`, not an error) and the change took effect without restarting the container
- [x] Verified the Nginx page is actually served, via `kubectl port-forward` + `curl`
- [x] Ran the extra `kubectl get` sweep (`pods`, `nodes`, `deployment`, `svc`, `rs`, `all`) to see what does/doesn't exist yet at this stage
