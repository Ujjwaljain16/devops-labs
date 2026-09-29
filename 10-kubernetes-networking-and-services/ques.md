# Assignment Breakdown - Kubernetes Networking & Services

---

## 1. What's required

- `pod.yaml`, a **hand-written** (not copy-pasted from the doc) Nginx Pod manifest using the four mandatory top-level fields: `apiVersion`, `kind`, `metadata`, `spec`.
- Proof the cluster tooling works: `minikube start`, `kubectl version`, `kubectl cluster-info`, `kubectl get nodes`.
- Proof the Pod deploys and comes up healthy: `kubectl apply -f pod.yaml`, followed by `kubectl get pods` showing `1/1 Running`.
- Proof I understand `apply` vs `create`, not just recite it: actually trigger the `AlreadyExists` error with `create`, then actually make a change and watch `apply` handle it cleanly.
- Proof the Nginx app is actually reachable, not just that the Pod object exists: port-forward and hit it with curl.

## 2. Notes

Service and selector mechanics are introduced only conceptually in this module, not as a submission requirement. There is no `service.yaml` here; labels and selectors as the connection mechanism a Service uses to find its Pods are explicitly the next stage, covered in a later session.

## 3. My completion checklist

- [x] Wrote `pod.yaml` by hand, an Nginx Pod with `apiVersion: v1`, `kind: Pod`, `metadata`, and `spec` with one container, image `nginx`, `containerPort: 80`
- [x] Confirmed Minikube running (`minikube start`, already up, addons re-confirmed)
- [x] Ran `kubectl version`, `kubectl cluster-info`, and `kubectl get nodes`, and checked all three
- [x] Deployed with `kubectl apply -f pod.yaml`, confirmed `1/1 Running` via `kubectl get pods`
- [x] Ran `kubectl create -f pod.yaml` against the already-applied Pod, captured the real `AlreadyExists` error
- [x] Edited `pod.yaml` (added a label), re-ran `kubectl apply -f pod.yaml`, confirmed `configured` (not `unchanged`, not an error) and that the change took effect without restarting the container
- [x] Verified the Nginx page is actually served, via `kubectl port-forward` and curl
- [x] Ran the extra `kubectl get` sweep (`pods`, `nodes`, `deployment`, `svc`, `rs`, `all`) to see what does and does not exist yet at this stage
