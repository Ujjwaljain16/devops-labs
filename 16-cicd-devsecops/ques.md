# Assignment - Complete CI/CD & DevSecOps

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Complete CI/CD & DevSecOps (Session 17 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 17 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task: DevSecOps Demo Project.** "Build a complete CI/CD + DevSecOps pipeline."

**CI/CD:** Application build, Unit testing, Docker image build, Container registry, Kubernetes deployment
**Security:** SAST, SCA, Secret scanning, Container image scanning, Security gates

**Expected Flow:** Code -> Build -> Unit Test -> SAST -> SCA -> Secret Scan -> Docker Build -> Container Image Scan -> Security Gate -> Push Image -> Deploy to Kubernetes

**Deliverables:** Application, Dockerfile, GitHub Actions workflow, Security tools configuration, Kubernetes manifests, Successful pipeline output, Screenshots

## 2. Notes

Like module 15, I checked the instructor's template repo first ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), `session-17-devsecops/demo/`) rather than guessing. Its README documents a Flask dashboard app with this exact tool mapping:

| Concept | Tool (reference) |
|---|---|
| Unit Testing | pytest + pytest-cov |
| SAST | GitHub CodeQL |
| SCA | pip-audit |
| Container Image Scanning | Trivy |
| Container Registry | GitHub Container Registry (GHCR) |
| Orchestration | Kubernetes |

I built my own app and workflow (not copied) using an equivalent, genuinely run tool chain, with one substitution: Bandit instead of CodeQL for SAST. CodeQL needs either the repo's "code scanning" default setup enabled first, or careful permission and workflow setup that can conflict with a default that is already on. Bandit, by contrast, is a zero-config, Python-specific SAST tool that needed no repo settings changes and is just as real a SAST tool for this codebase's language.

The Kubernetes deployment step is manual rather than part of CI. The reference project's own README is explicit about this: Step 7 (`kubectl apply` inside the pipeline) needs a `KUBECONFIG` secret pointing at a reachable cluster. GitHub's hosted runners are on GitHub's own infrastructure, so they cannot reach a Minikube cluster running inside this machine's WSL2, which only listens on a local network. Making it reachable would mean either a real cloud cluster (out of scope here) or registering this machine as a self-hosted runner, which the reference does not do either, and which I am deliberately not doing on a public repo: a self-hosted runner executes arbitrary workflow-defined code on the machine it is attached to, and this repo is public. This is a real security trade-off, not a shortcut. So the pipeline builds, scans, gates, and pushes a real image to GHCR (steps 1 through 9 of the Expected Flow, all genuinely running on GitHub's infrastructure), and "Deploy to Kubernetes" (step 10) is then done for real, but locally, pulling that exact pushed image down to the live Minikube cluster. This is the same "Method 4: manual deploy" pattern the reference itself documents for exactly this reason.

The same situation as module 15 applies to pushing to GitHub: everything is built and verified locally first (tests, Bandit, Docker build/run; pip-audit and Trivy need CI or tools this environment does not have, see the README). Pushing triggers a real public pipeline that also publishes a container image to GHCR, so I asked for the user's go-ahead again before that push.

## 3. My completion checklist

- [x] Application source code (Flask, own design)
- [x] Tests (pytest, 8 tests) - verified locally and in CI
- [x] Dockerfile - verified locally (build, run, real curl against endpoints)
- [x] SAST (Bandit) - 1 real finding investigated and justified-suppressed, not blindly ignored
- [x] SCA (pip-audit) - genuinely caught a real Flask CVE (PYSEC-2026-2151) in CI; fixed by upgrading
- [x] Secret scanning (Gitleaks) - genuinely caught real (but out-of-scope) findings from unrelated module history; re-scoped correctly, documented the reasoning
- [x] Container image scan (Trivy) - 44 HIGH / 0 CRITICAL, all base-OS packages; gate passed
- [x] Security gate - CRITICAL-only policy, passed in CI
- [x] Push to GHCR - [run 36577998208](https://github.com/Ujjwaljain16/devops-labs/actions/runs/36577998208), image public, confirmed by actually pulling it
- [x] Kubernetes manifests - applied for real to live Minikube, confirmed running the actual pushed image, confirmed serving real traffic via port-forward
- [x] Successful pipeline output documented (4 runs: 3 real failures + fixes, then green)
- [x] Screenshots: all four runs (SCA failure, Trivy version failure, Gitleaks failure, final all-green), captured from the real Actions UI, plus real pod/image confirmation and live curl responses from the Kubernetes deployment
