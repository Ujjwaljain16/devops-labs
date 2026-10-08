# Assignment - Kubernetes Storage, HPA & Probes

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Storage, HPA & Probes (Session 13, 10 Sep per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 13 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Kubernetes Volumes** (in [01-kubernetes-volumes/README.md](01-kubernetes-volumes/README.md), as the doc explicitly asks for a dedicated sub-README)
1. Document, with practical examples wherever possible:
   - `emptyDir`
   - `hostPath`
   - `PersistentVolume`
   - `PersistentVolumeClaim`
   - `StorageClass`
   - Dynamic provisioning

**Task 2: HPA Hands-on** (in [02-hpa/](02-hpa/), proof in the main [README.md](README.md))
2. Using `hpa.yml`:
   1. Deploy the application.
   2. Configure HPA.
   3. Verify HPA.
   4. Deploy a load generator.
   5. Increase application load.
   6. Observe CPU utilization.
   7. Observe Pod scaling.
   8. Capture the output.
   9. Add the output/screenshots to README.md.
   - Useful commands: `kubectl get hpa`, `kubectl get pods`, `kubectl top pods`, `kubectl describe hpa`

**Task 3: Mini Project** (in [03-mini-project/](03-mini-project/README.md))
3. "Complete the mini project provided for Session 13." The doc tab has no brief, spec or link of its own. The brief is the instructor's `mini-project/` folder in the Session 13 materials of their reference repository ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), `session-13-storage-hpa-probes/mini-project/`): a production-style nginx Deployment with a PVC mounted at `/data`, an HPA (2 to 5 replicas at 50% CPU) and startup, readiness and liveness probes, with three verification tasks (storage persistence, Service check, HPA scaling) and three optional bonus challenges. I first marked this blocked because I had only looked at the doc tab, and I should have checked the reference repository first.

**Task 4: Probes** (in [04-probes/](04-probes/README.md))
4. The session title includes "Probes", but the doc's task list has no Probes task. The same instructor folder has a dedicated `05-probes/` with `liveness.yaml`, `readiness.yaml`, `startup.yaml` and a guide, including two "try breaking it" exercises (a wrong readiness path and a wrong liveness path) and a debugging section. I treated that as the brief.

## 2. Notes

Both things I had marked as open (the Mini Project, and whether Probes needed its own work) were resolved by reading the instructor's reference repository, which has a `mini-project/` folder and a `05-probes/` folder for this session. The manifests I took from there are the instructor's, unchanged and verified byte-identical; the only files I wrote are two one-line variants for the "try breaking it" exercises (`04-probes/liveness-broken.yaml`, `04-probes/readiness-broken.yaml`) and one for bonus challenge 2 (`03-mini-project/deployment-readiness-broken.yaml`). Basic liveness and readiness probes were also covered earlier, in [module 09](../09-kubernetes-pods-replicasets-deployments/README.md)'s `pod-lifecycle/` folder.

## 3. My completion checklist

- [x] Volumes: emptyDir example, deployed and verified (two containers sharing one file, proven from both sides)
- [x] Volumes: hostPath example, deployed and verified (cross-checked via `kubectl exec` and `minikube ssh` reading the node's own disk)
- [x] Volumes: PersistentVolume + PersistentVolumeClaim, bound and verified (`demo-pv` <-> `demo-pvc`, `Bound`, data written through the claim)
- [x] Volumes: StorageClass + dynamic provisioning, verified against Minikube's default `standard` StorageClass / storage-provisioner addon (auto-generated PV `pvc-dfc8c7ed-...`, no PV manifest written by hand)
- [x] HPA: application deployed with resource requests set (required for HPA to compute utilization): `registry.k8s.io/hpa-example`, `requests.cpu: 200m`
- [x] HPA: `hpa.yml` applied, `kubectl get hpa` shows real target/current CPU% (started `<unknown>`, settled to real `0%/50%` once metrics-server completed its first scrape)
- [x] HPA: load generator applied, CPU utilization climbs, `kubectl get hpa` / `kubectl top pods` show real scale-up (0% -> 80% -> 173%, replicas 1 -> 2 -> 4 -> 5, capped at `maxReplicas: 5`)
- [x] HPA: output captured (raw `kubectl get hpa`/`top pods` polling log + `kubectl describe hpa` event history with real `SuccessfulRescale` events) in the module README
- [x] Screenshots: HPA at 5/5 replicas, PV/PVC bound state, dynamic PVC file verification, all in place
- [x] Mini Project: namespace, PVC (dynamic provisioning), Deployment with all three probes, Service and HPA applied from the instructor's unchanged manifests
- [x] Mini Project, storage persistence: file written through one Pod, read from a replacement; then proved properly by scaling to zero Pods (claim stayed `Bound`) and reading it from two brand-new Pods
- [x] Mini Project, Service: endpoints are exactly the two Pod IPs, and `curl` through a port-forward returns the nginx page
- [x] Mini Project, HPA scale-up: six load generators took it from 2 to 4 replicas, where it settled at about 53% (inside the 10 percent tolerance), captured twice, with the `<unknown>` start-up period and the metrics lag documented
- [x] Mini Project, HPA scale-down: load removed at 12:59:27 UTC, metric at `1%` by 13:02, replicas dropped 4 to 2 at about 13:06:13 (the 5-minute stabilization window), with both cycles' rescale events in the log
- [x] Mini Project, bonus challenge 2: wrong readiness path on the real Deployment gave `0/2` available, empty endpoints and `Connection refused` (with `strategy: Recreate` the old Pods were gone), then restored and verified. Bonus challenges 1 and 3 not done (3 is covered in Probes)
- [x] Probes: liveness, readiness and startup demos deployed healthy, with their probe configuration read from `describe`
- [x] Probes, readiness break: Pod `Running` but `0/1`, Service endpoints empty, `restartCount=0`
- [x] Probes, liveness break: container restarted repeatedly, `CrashLoopBackOff`, with the `Unhealthy` / `Killing` / `BackOff` events and a last-state exit code of 0
- [x] Probes, finding: the guide's "edit the path and `kubectl apply`" is rejected for a running Pod (probe fields are immutable); the Pod must be deleted and recreated
- [x] Probes, debugging: reproduced the probe's request from inside a container (`/` returns 200, `/wrong-path` returns 404)
- [x] Screenshot of the broken readiness and liveness Pods together with the mini project's PVC, Deployment, Service and HPA (one capture, used in both READMEs; it also documents that the `RESTARTS 1` on `readiness-demo` came from the cluster restart, not the probe)
- [x] Screenshot of the persistence test (file written, scale to zero, scale back to 2, file read from brand-new Pods, PVC `Bound` throughout), with the caption noting that this capture caught the old Pods still `Terminating`
- [x] Screenshot of the HPA scaled out: `52%/50%`, 4 replicas, all four web Pods at 52m-53m, six load generators running (a third run that reproduced the same equilibrium as the first two)
- [ ] Optional, not captured: the scale-down shot, the bonus-challenge-2 outage and the Service check; the text and real outputs for all of them are already in the READMEs
