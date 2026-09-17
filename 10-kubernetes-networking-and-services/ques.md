# Assignment Breakdown — Kubernetes Networking & Services

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Networking & Services
**Date:** 7 September 2026
**Source:** Instructor's session transcript. Same caveat as the last couple of these: the transcript is auto-generated speech-to-text and doesn't give a deadline, submission portal, marks, or a required screenshot count — this file only claims what the transcript actually says.

The execution/proof for everything below lives in [README.md](README.md).

---

## 1. What's actually being asked

Despite the lecture title, almost none of this class is actually about Services yet — it's about writing your **first hand-written Pod manifest** and understanding `apply` vs `create`. Service/labels/selectors get introduced conceptually as the *next* topic, explicitly not assigned here. I got two independent descriptions of this same session (one a numbered task list, one the full transcript writeup below) and cross-checked them — they match almost 1:1, just phrased differently:

| Task | Numbered list said | Transcript doc said |
|---|---|---|
| Write the Pod manifest by hand | "Write `pod.yaml` by hand yourself (not copy-pasted)" | §3.1 "Create pod.yaml yourself," same 4 mandatory fields |
| Confirm cluster is up | `minikube start` if needed, `kubectl version`, `cluster-info`, `get pods`, `get nodes` | §4 (`minikube start`, `version`, `cluster-info`) + §6.1/§7 |
| Deploy & verify | `kubectl apply -f pod.yaml`, confirm `1/1 Running` | §5 + §6.1, same `1/1 Running` check |
| `apply` vs `create` | Run `create` twice on an existing Pod (expect error), then edit + re-`apply` (expect clean update) | §5.1, same mechanic described |
| What's next, not yet assigned | Optional: read `core-objects.md` previewing RS/Deployment/Service | §8: Service/labels/selectors framed as "next stage," not assigned here |

## 2. The actual deliverable

- `pod.yaml` — a **hand-written** (not copy-pasted from the doc) Nginx Pod manifest using the four mandatory top-level fields: `apiVersion`, `kind`, `metadata`, `spec`.
- Proof the cluster tooling works: `minikube start`, `kubectl version`, `kubectl cluster-info`, `kubectl get nodes`.
- Proof the Pod deploys and comes up healthy: `kubectl apply -f pod.yaml` → `kubectl get pods` → `1/1 Running`.
- Proof I understand `apply` vs `create`, not just recite it: actually trigger the `AlreadyExists` error with `create`, then actually make a change and watch `apply` handle it cleanly.
- Proof the Nginx app is actually reachable, not just "the Pod object exists": port-forward and hit it with `curl`.

## 3. Deliberately not part of this assignment

Per the transcript (§8, §9):

- `service.yaml`, Services, labels/selectors as a connection mechanism — introduced conceptually as the next stage, explicitly not required as a submission for this session
- Any exact deadline, submission portal, marks/weightage, or required screenshot count — none of these are stated
- The earlier "learn YAML" homework (§2 of the transcript doc) — that's a prerequisite that predates this class, not part of this session's deliverable

## 4. My completion checklist

- [x] Wrote `pod.yaml` by hand — Nginx Pod, `apiVersion: v1` / `kind: Pod` / `metadata` / `spec` with one container, image `nginx`, `containerPort: 80`
- [x] Confirmed Minikube running (`minikube start` — already up, addons re-confirmed)
- [x] `kubectl version`, `kubectl cluster-info`, `kubectl get nodes` all run and checked
- [x] Deployed with `kubectl apply -f pod.yaml`, confirmed `1/1 Running` via `kubectl get pods`
- [x] Ran `kubectl create -f pod.yaml` against the already-applied Pod, captured the real `AlreadyExists` error
- [x] Edited `pod.yaml` (added a label), re-ran `kubectl apply -f pod.yaml`, confirmed `configured` (not `unchanged`, not an error) and the change took effect without restarting the container
- [x] Verified the Nginx page is actually served, via `kubectl port-forward` + `curl`
- [x] Ran the extra `kubectl get` sweep (`pods`, `nodes`, `deployment`, `svc`, `rs`, `all`) to see what does/doesn't exist yet at this stage
