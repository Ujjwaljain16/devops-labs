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

**Task 3: Mini Project**
3. "Complete the mini project provided for Session 13." The doc tab has no further detail (no attached brief, spec, or link on the tab itself). I am flagging this as blocked until the actual mini-project brief is available, rather than fabricating a project to fill the gap.

## 2. Notes

See [gaps.md](gaps.md) for the two open items (the Task 3 Mini Project brief, and whether Probes needs dedicated hands-on work here); both need information only I have.

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
- [ ] Mini Project: blocked, see [gaps.md](gaps.md)
