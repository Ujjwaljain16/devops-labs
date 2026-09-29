# Assignment - Kubernetes Troubleshooting

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Kubernetes Troubleshooting (Session 14 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 14 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Kubernetes Commands.** Hands-on practice with `kubectl get`, `kubectl describe`, `kubectl logs`, `kubectl exec`, `kubectl get events`, `kubectl explain`, `kubectl top`, and `kubectl get -o wide`.

**Task 2: Troubleshoot Common Issues.** Reproduce and fix a genuinely broken Pod for each of nine failure categories (CrashLoopBackOff, ImagePullBackOff, ErrImagePull, Pending, ContainerCreating, Service connectivity issues, DNS issues, Pod networking issues, and Configuration issues), following the doc's six-step method: identify the problem, investigate, find the root cause, fix it, verify the solution, and document the process.

**Task 3: Mini Project.** "Complete the Kubernetes troubleshooting mini project," with deliverables of commands, problem statement, investigation steps, root cause, solution, before/after output, screenshots, and a README.

**Deliverables:** kubectl command demonstrations, nine reproduced-and-fixed issues, a formal report for each issue, screenshots, README.md.

## 2. Notes

Task 3 is not a separate section in the README. Its deliverable list is exactly the same identify, investigate, root cause, fix, verify, document workflow that Task 2 already asks for, just spelled out as a formal report format, so I satisfied it by documenting each Task 2 issue in that exact shape within the README rather than building a separate standalone project.

Module 09's `troubleshooting/` folder already has `selector-mismatch.yaml` and `broken-image.yaml` demos from the Pods/ReplicaSets/Deployments session. This module goes deeper and wider, with the full `kubectl` diagnostic toolkit in Task 1 plus nine distinct failure categories documented in the formal identify/investigate/root-cause/fix/verify/document format, rather than just a broken thing and its fix.

## 3. My completion checklist

- [x] Task 1: all 8 kubectl commands demonstrated with real output against live cluster resources
- [x] CrashLoopBackOff: reproduced (real `cat: No such file` crash loop), diagnosed, fixed (ConfigMap mount), verified (0 restarts)
- [x] ImagePullBackOff: reproduced, diagnosed, fixed, verified
- [x] ErrImagePull: captured from the same broken image reference as ImagePullBackOff (real sequence: ErrImagePull -> ImagePullBackOff)
- [x] Pending: reproduced (32-core request vs. 4-core node), diagnosed, fixed, verified
- [x] ContainerCreating (stuck): reproduced (missing ConfigMap volume), diagnosed, fixed, verified
- [x] Service connectivity issues: reproduced (selector mismatch, empty Endpoints), diagnosed, fixed, verified
- [x] DNS issues: reproduced (typo and wrong namespace, real NXDOMAIN), diagnosed, fixed, verified
- [x] Pod networking issues: reproduced (wrong targetPort, Endpoints exist but refused), diagnosed, fixed, verified
- [x] Configuration issues: reproduced (missing ConfigMap key, CreateContainerConfigError), diagnosed, fixed, verified
- [x] Task 3 report format (Commands/Problem statement/Investigation steps/Root cause/Solution/Before-after output) applied to each issue in README.md
- [x] Screenshots: all pods Running, DNS resolution fixed, CrashLoopBackOff events
