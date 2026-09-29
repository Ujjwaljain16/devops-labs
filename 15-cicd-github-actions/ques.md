# Assignment - CI/CD & GitHub Actions

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** CI/CD & GitHub Actions (Session 16 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 16 tab

The commands, real output and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task: Demo Project.** "Build a complete CI/CD demo project using GitHub Actions." It refers to `10-final-cicd-pipeline` as a reference point.

The project should cover: CI vs CD, CI/CD pipeline, GitHub Actions, Workflow, Jobs, Steps, Runners, Secrets, Artifacts, Build, Test, Pipeline execution.

**Deliverables:**
- Application source code
- Dockerfile
- GitHub Actions workflow
- CI pipeline
- CD pipeline
- Screenshots of successful pipeline execution
- README.md

## 2. Notes

The doc does not attach the "10-final-cicd-pipeline" reference. It turned out to be a folder in the instructor's own template repo ([Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros), linked from the tracking doc's own README, with 180 forks, which is genuinely the class's shared starting point, not a guess). Its `session-16-github-actions/.../10-final-cicd-pipeline/README.md` lays out the expected shape: a small Python app (their example is a calculator) with pytest tests, three jobs (`test` -> `build` via `needs: test` -> `security-check`) running on `ubuntu-latest`, a build job that uploads an artifact, and a deliberate break-the-test-then-fix-it cycle to prove `needs: test` actually gates the build. I built my own version of this (own app, own tests, own workflow) rather than copying their code, so it is the same educational shape but genuinely my own work.

Task 2's deliverable list asks for a "CD pipeline", but Session 16's reference project explicitly stops at "Ready for CD / Deployment" and says deployment (Docker/K8s/AWS/Azure) is *next session's* material (Session 17: DevSecOps, per its own README). So "CD" here means that the build job produces a deployable artifact, a Docker image pushed to a registry. Actual deployment to a live target is Session 17's job (module 16 in this repo), not this one.

Everything below (app, tests, Dockerfile, workflow file) is built and verified locally first. Actually seeing it run, which is the whole point of "screenshots of successful pipeline execution", needs a real `git push` to `Ujjwaljain16/devops-labs`, which triggers a real, publicly visible GitHub Actions run. I build and verify everything locally, then stop and ask for the user's go-ahead before that push, and again before the deliberate break-it push.

## 3. My completion checklist

- [x] Application source code (Python, own design: unit converter)
- [x] Tests (pytest, 5 tests)
- [x] Dockerfile, verified locally (build and run)
- [x] GitHub Actions workflow: test -> build (needs: [test, security-check]), artifact upload
- [x] Verified locally (pytest, docker build) before any push
- [x] Pushed (user approved): [run 36575952176](https://github.com/Ujjwaljain16/devops-labs/actions/runs/36575952176), all 3 jobs green
- [x] Break-it-then-fix-it cycle: real red X ([run 36576115091](https://github.com/Ujjwaljain16/devops-labs/actions/runs/36576115091), Build skipped) then real green check ([run 36576224924](https://github.com/Ujjwaljain16/devops-labs/actions/runs/36576224924))
- [x] Screenshots: initial run, broken run, and fixed run, all captured from the real Actions UI
