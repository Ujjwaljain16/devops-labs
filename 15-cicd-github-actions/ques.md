# Assignment - CI/CD & GitHub Actions

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** CI/CD & GitHub Actions (Session 16 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 16 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task: Demo Project** — "Build a complete CI/CD demo project using GitHub Actions." Refers to `10-final-cicd-pipeline` as a reference point.

The project should cover: CI vs CD, CI/CD pipeline, GitHub Actions, Workflow, Jobs, Steps, Runners, Secrets, Artifacts, Build, Test, Pipeline execution.

**Deliverables:**
- Application source code
- Dockerfile
- GitHub Actions workflow
- CI pipeline
- CD pipeline
- Screenshots of successful pipeline execution
- README.md

## 2. About the "10-final-cicd-pipeline" reference

The doc doesn't attach this — it turned out to be a folder in the instructor's own template repo ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), linked from the tracking doc's own README, 180 forks — this is genuinely the class's shared starting point, not a guess). Its `session-16-github-actions/.../10-final-cicd-pipeline/README.md` lays out the expected shape:

- A small Python app (their example: a calculator) with pytest tests
- Three jobs: `test` -> `build` (via `needs: test`) -> `security-check`
- `runs-on: ubuntu-latest`
- Build job uploads an artifact
- A deliberate break-the-test-then-fix-it cycle, to prove `needs: test` actually gates the build

I built my **own** version of this (own app, own tests, own workflow) rather than copying their code — same educational shape, genuinely my own work.

## 3. What "CD" means here

Task 2's deliverable list asks for a "CD pipeline" but Session 16's reference project explicitly stops at "Ready for CD / Deployment" and says deployment (Docker/K8s/AWS/Azure) is *next session's* material (Session 17: DevSecOps, per its own README). So "CD" here means: the build job produces a deployable artifact (a Docker image, pushed to a registry) — actual deployment to a live target is Session 17's job (module 16 in this repo), not this one.

## 4. Pushing to GitHub — needs your go-ahead

Everything below (app, tests, Dockerfile, workflow file) is built and verified locally first. Actually seeing it run — the whole point of "screenshots of successful pipeline execution" — needs a real `git push` to `Ujjwaljain16/devops-labs`, which triggers a real, publicly-visible GitHub Actions run. I build and verify everything locally, then stop and ask before that push (and again before the deliberate break-it push).

## 5. My completion checklist

- [ ] Application source code (Python, own design)
- [ ] Tests (pytest)
- [ ] Dockerfile
- [ ] GitHub Actions workflow: test -> build (needs: test) -> security-check, artifact upload
- [ ] Verified locally (pytest, docker build) before any push
- [ ] Pushed (pending user go-ahead) and pipeline runs green
- [ ] Break-it-then-fix-it cycle, real red X then real green check
- [ ] Screenshots of both the failing and passing runs
