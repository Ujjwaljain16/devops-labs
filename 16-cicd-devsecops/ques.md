# Assignment - Complete CI/CD & DevSecOps

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Complete CI/CD & DevSecOps (Session 17 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 17 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task: DevSecOps Demo Project** — "Build a complete CI/CD + DevSecOps pipeline."

**CI/CD:** Application build, Unit testing, Docker image build, Container registry, Kubernetes deployment
**Security:** SAST, SCA, Secret scanning, Container image scanning, Security gates

**Expected Flow:** Code -> Build -> Unit Test -> SAST -> SCA -> Secret Scan -> Docker Build -> Container Image Scan -> Security Gate -> Push Image -> Deploy to Kubernetes

**Deliverables:** Application, Dockerfile, GitHub Actions workflow, Security tools configuration, Kubernetes manifests, Successful pipeline output, Screenshots

## 2. About the reference

Like module 15, checked the instructor's template repo first ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), `session-17-devsecops/demo/`) rather than guessing. Its README documents a Flask dashboard app with this exact tool mapping:

| Concept | Tool (reference) |
|---|---|
| Unit Testing | pytest + pytest-cov |
| SAST | GitHub CodeQL |
| SCA | pip-audit |
| Container Image Scanning | Trivy |
| Container Registry | GitHub Container Registry (GHCR) |
| Orchestration | Kubernetes |

Built my **own** app and workflow (not copied) using an equivalent, genuinely-run tool chain — with one substitution: **Bandit instead of CodeQL for SAST**. CodeQL needs either the repo's "code scanning" default setup enabled first, or careful permission/workflow setup that can conflict with a default that's already on; Bandit is a zero-config, Python-specific SAST tool that needed no repo settings changes and is just as real a SAST tool for this codebase's language.

## 3. The Kubernetes deployment step - why it's manual, not in CI

The reference project's own README is explicit about this: Step 7 (`kubectl apply` inside the pipeline) needs a `KUBECONFIG` secret pointing at a **reachable** cluster. GitHub's hosted runners are on GitHub's own infrastructure - they cannot reach a Minikube cluster running inside this machine's WSL2, which only listens on a local network. Making it reachable would mean either a real cloud cluster (out of scope here) or registering this machine as a **self-hosted runner** - which the reference doesn't do either, and which I'm deliberately not doing on a public repo: a self-hosted runner executes arbitrary workflow-defined code on the machine it's attached to, and this repo is public. That's a real security trade-off, not a shortcut.

So: the pipeline builds, scans, gates, and pushes a real image to GHCR (steps 1-9 of the Expected Flow, all genuinely running on GitHub's infrastructure). "Deploy to Kubernetes" (step 10) is then done for real, but locally - pulling that exact pushed image down to the live Minikube cluster, the same "Method 4: manual deploy" pattern the reference itself documents for exactly this reason.

## 4. Pushing to GitHub — needs your go-ahead (again)

Same situation as module 15: everything is built and verified locally first (tests, Bandit, Docker build/run; pip-audit and Trivy need CI or tools this environment doesn't have — see README). Pushing triggers a real public pipeline that also **publishes a container image to GHCR** — asking again before that push.

## 5. My completion checklist

- [ ] Application source code (Flask, own design)
- [ ] Tests (pytest, 8 tests) - verified locally
- [ ] Dockerfile - verified locally (build, run, real curl against endpoints)
- [ ] SAST (Bandit) - verified locally, 1 real finding investigated and justified-suppressed, not blindly ignored
- [ ] SCA (pip-audit) - needs CI (local venv unavailable, same gap as module 15)
- [ ] Secret scanning (Gitleaks) - CI only
- [ ] Container image scan (Trivy) - verified locally, real findings (44 HIGH / 0 CRITICAL, all base-OS packages)
- [ ] Security gate - gates on CRITICAL only (documented reasoning)
- [ ] Push to GHCR - pending user go-ahead
- [ ] Kubernetes manifests - written, pending real deploy against Minikube after push
- [ ] Successful pipeline output + screenshots - pending push
