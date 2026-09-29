# Assignment - Monitoring, Observability & GitOps

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Monitoring, Observability & GitOps (Session 20 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 20 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Monitoring.** Learn and demonstrate metrics, logs, alerts, CPU utilization, memory utilization, and application health.

**Task 2: Observability.** Understand the three major pillars (metrics, logs, traces). Document what each pillar means, why observability is required, common tools, and Kubernetes observability.

**Task 3: GitOps.** Learn what GitOps is, Git as the source of truth, declarative configuration, continuous reconciliation, the GitOps workflow, and Kubernetes with GitOps.

**Deliverables:** monitoring demo, observability documentation, GitOps demo, screenshots, README.md.

## 2. Notes

I checked the instructor's template repo first ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), `session20-monitoring-observability-gitops/`), the same as I did for modules 15 and 16. It maps Prometheus to metrics, Grafana to dashboards, and Argo CD to GitOps, and its `08-mini-project/README.md` gives a detailed step-by-step Argo CD walkthrough that I followed closely.

I ran this module on a separate Minikube profile (`session19`) instead of the main cluster. The reference project does the same with a fresh `kind` cluster, and my main cluster already carries five other modules' worth of live resources, so keeping this one separate avoided resource contention on a machine with only about 3.9GB of RAM available to WSL2.

I used this same repository as the GitOps source rather than creating a separate one. The app manifests live at `19-monitoring-observability-gitops/gitops-app/app/`, and Argo CD's `Application` resource points at that exact path. I kept `argocd-application.yaml` one level outside `app/` so it is never mistaken for a workload manifest to sync.

Pushing the GitOps manifests to GitHub did not trigger any CI workflow or publish an image, but it was still a push to a public repository, so I asked for the user's go-ahead first, the same as every other push in this project.

## 3. My completion checklist

- [x] Task 1: metrics, logs, CPU/memory utilization, and application health, all demonstrated with real data
- [x] Task 1: alerts, full real lifecycle (inactive, pending, firing in both Prometheus and Alertmanager, then resolved), including a genuine `up==0` vs `absent()` issue found and fixed, not just a static rule
- [x] Task 2: observability documentation (three pillars, why it matters, common tools, Kubernetes observability), honest about the one gap (no real tracing backend was stood up)
- [x] Task 3: full Argo CD GitOps demo, install (including a real CRD-size apply issue found and fixed), sync, verify, replica change via a real git push, watched reconciliation, self-healing demonstrated with real event log proof
- [x] Screenshots: Argo CD Synced/Healthy, monitoring pods Running, final 3/3 deployment state
