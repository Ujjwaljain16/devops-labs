# Assignment - Kubernetes Troubleshooting

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Troubleshooting (Session 14 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 14 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Kubernetes Commands** — hands-on practice with all the important troubleshooting commands:
`kubectl get`, `kubectl describe`, `kubectl logs`, `kubectl exec`, `kubectl events`, `kubectl explain`, `kubectl top`, `kubectl get -o wide`

**Task 2: Troubleshoot Common Issues** — practice troubleshooting, for real, against a genuinely broken Pod for each:
- CrashLoopBackOff
- ImagePullBackOff
- ErrImagePull
- Pending
- ContainerCreating
- Service connectivity issues
- DNS issues
- Pod networking issues
- Configuration issues

For every issue, the doc's exact 6-step method:
1. Identify the problem.
2. Investigate.
3. Find the root cause.
4. Fix it.
5. Verify the solution.
6. Document the troubleshooting process.

**Task 3: Mini Project** — "Complete the Kubernetes troubleshooting mini project." Deliverables, per the doc:
- Commands
- Problem statement
- Investigation steps
- Root cause
- Solution
- Before/after output
- Screenshots
- README.md

Unlike module 12's Session 13 mini project (no brief anywhere), this one is **not blocked** — its deliverable list is exactly the same identify -> investigate -> root cause -> fix -> verify -> document workflow Task 2 already asks for, just spelled out as a formal report format. So Task 3 is satisfied by documenting each Task 2 issue in that exact shape, in the README, rather than a separate standalone project.

## 2. Related but deliberately not repeated here

Module 09's `troubleshooting/` folder already has `selector-mismatch.yaml` and `broken-image.yaml` demos from the Pods/ReplicaSets/Deployments session. This module goes deeper and wider — full `kubectl` diagnostic toolkit (Task 1) plus 9 distinct failure categories with the formal identify/investigate/root-cause/fix/verify/document report format Task 3 asks for, not just "here's a broken thing and the fix."

## 3. My completion checklist

- [x] Task 1: all 8 kubectl commands demonstrated with real output against live cluster resources
- [x] CrashLoopBackOff: reproduced (real `cat: No such file` crash loop), diagnosed, fixed (ConfigMap mount), verified (0 restarts)
- [x] ImagePullBackOff: reproduced, diagnosed, fixed, verified
- [x] ErrImagePull: captured from the same broken image reference as ImagePullBackOff (real sequence: ErrImagePull -> ImagePullBackOff)
- [x] Pending: reproduced (32-core request vs. 4-core node), diagnosed, fixed, verified
- [x] ContainerCreating (stuck): reproduced (missing ConfigMap volume), diagnosed, fixed, verified
- [x] Service connectivity issues: reproduced (selector mismatch, empty Endpoints), diagnosed, fixed, verified
- [x] DNS issues: reproduced (typo + wrong namespace, real NXDOMAIN), diagnosed, fixed, verified
- [x] Pod networking issues: reproduced (wrong targetPort, Endpoints exist but refused), diagnosed, fixed, verified
- [x] Configuration issues: reproduced (missing ConfigMap key, CreateContainerConfigError), diagnosed, fixed, verified
- [x] Task 3 report format (Commands/Problem statement/Investigation steps/Root cause/Solution/Before-after output) applied to each issue in README.md
- [ ] Screenshots — pending user handoff
