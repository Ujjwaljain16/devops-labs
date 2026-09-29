# Assignment - Monitoring, Observability & GitOps

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Monitoring, Observability & GitOps (Session 20 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 20 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Monitoring** — learn and demonstrate: Metrics, Logs, Alerts, CPU utilization, Memory utilization, Application health

**Task 2: Observability** — understand the three major pillars (Metrics, Logs, Traces); document what each pillar means, why observability is required, common tools, Kubernetes observability

**Task 3: GitOps** — learn: What is GitOps?, Git as the source of truth, Declarative configuration, Continuous reconciliation, GitOps workflow, Kubernetes + GitOps

**Deliverables:** Monitoring demo, Observability documentation, GitOps demo, Screenshots, README.md

## 2. About the reference

Checked the instructor's template repo first ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), `session20-monitoring-observability-gitops/`), same as modules 15/16. Its tool mapping: **Prometheus** (metrics), **Grafana** (dashboards), **Argo CD** (GitOps). Its `08-mini-project/README.md` is an unusually detailed step-by-step Argo CD walkthrough (fresh cluster -> install Argo CD -> Git repo with app manifests -> Argo CD Application -> watch sync -> change replicas in Git -> watch reconciliation -> demonstrate self-healing) — followed that shape closely since it's genuinely reproducible, just substituting a second Minikube profile for their `kind` cluster (see §3) and this repo for "your GitOps repo" (see §4).

## 3. Why a separate cluster

The main `minikube` cluster already carries 5 modules' worth of live resources (33+ pods across modules 08-16). The reference project itself creates a brand-new cluster specifically for this exercise (`kind create cluster --name session20`) rather than reusing one - clearly deliberate, to avoid resource contention and to not risk destabilizing already-proven module state. Did the same: `minikube start -p session19` (2 CPU, 1800MB), same underlying concept, one Minikube feature instead of a second tool.

Even so, WSL2's ~3.9GB total RAM meant staying deliberately lightweight: Prometheus/Grafana installed via Helm with `persistence.enabled=false`, trimmed resource requests, and no `kube-prometheus-stack` (too heavy for this environment) - a standalone `prometheus` chart + standalone `grafana` chart instead.

## 4. GitOps repo - using this same repo

The reference says "create a repository on GitHub/GitLab/Bitbucket" for the app manifests Argo CD watches. Used **this repo** (`Ujjwaljain16/devops-labs`) rather than spinning up a separate one - the app manifests live at `19-monitoring-observability-gitops/gitops-app/app/`, and Argo CD's `Application` resource points its `repoURL`/`path` at exactly that location. Per the reference's own note, `argocd-application.yaml` itself lives one level up, **outside** `app/`, so it isn't mistaken for one of the workload manifests Argo CD syncs from that path.

## 5. Pushing to GitHub — needs your go-ahead

Unlike modules 15/16, this push doesn't trigger any CI workflow (no path matches an existing `on.push.paths` filter) or publish an image - it's just committing the GitOps app manifests so Argo CD (watching the real GitHub repo, not a local path) has something to sync from. Still a push to a public repo, so asking first, same policy as every other push this session.

## 6. My completion checklist

- [x] Task 1: Metrics, Logs, CPU/Memory utilization, Application health - all demonstrated with real data
- [x] Task 1: Alerts - full real lifecycle (inactive -> pending -> firing in Prometheus AND Alertmanager -> resolved), including a genuine `up==0` vs `absent()` gotcha found and fixed, not just a static rule
- [x] Task 2: Observability documentation (3 pillars, why it matters, common tools, Kubernetes observability) - honest about the one gap (no real tracing backend stood up)
- [x] Task 3: Full Argo CD GitOps demo - install (incl. a real CRD-size apply issue found and fixed), sync, verify, replica change via real git push, watched reconciliation, demonstrated self-healing with real event log proof
- [x] Screenshots - Argo CD Synced/Healthy, monitoring pods Running, final 3/3 deployment state
