# Assignment - Helm

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Helm (Session 15 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 15 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Helm Commands** — hands-on practice with every command below. For each: execute it, understand what it does, capture the output, document it.
`helm create`, `helm install`, `helm list`, `helm status`, `helm get`, `helm upgrade`, `helm history`, `helm rollback`, `helm uninstall`, `helm repo`, `helm search`

**Task 2: Helm Rollback** — a complete workflow, documented end to end:
Install -> Upgrade -> Verify -> Upgrade again -> Verify -> Rollback -> Verify

**Task 3: Mini Project** — "Complete the Helm mini project." Deliverables: Helm chart, `values.yaml`, Templates, Installation, Upgrade, Rollback, Screenshots, README files.

Same situation as module 13's mini project, different from module 12's: the deliverable list here is exactly what Tasks 1 + 2 already produce (a real chart with `values.yaml` and templates, taken through install/upgrade/rollback). So Task 3 isn't a separate build — it's satisfied by the one real chart built for Tasks 1/2, documented properly.

## 2. Environment note

Helm wasn't installed in WSL. Installed it as a user-local binary (`~/bin/helm`, from the official `get.helm.sh` v3.16.3 tarball) rather than asking for a `sudo` password mid-session — no root needed, matches this repo's existing Minikube/kubectl setup.

## 3. My completion checklist

- [x] Task 1: all 11 helm commands demonstrated with real output (create, install, list, status, get values/manifest, upgrade, history, rollback, uninstall, repo add/list/update, search repo/hub)
- [x] Task 2: full install -> upgrade -> verify -> upgrade -> verify -> rollback -> verify workflow, real revisions (1 -> 2 -> 3 -> 4/rollback-to-2), each verified against actual Pod counts and image tags, not just `helm`'s own success message
- [x] Task 3: satisfied by the one real chart (`myapp-chart/`) + its full lifecycle above
- [ ] Screenshots — pending user handoff
