# Complete CI/CD & DevSecOps

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for the exact task, the reference project this is modeled on, and why Bandit replaces CodeQL and why "Deploy to Kubernetes" is a manual step rather than a CI job.

---

## Application

A small Flask app (`app/app.py`), own design: `/`, `/health`, `/api/status`, `/api/add`, `/api/calculate` (add/subtract/multiply/divide).

## Unit Test

8 pytest tests (`tests/test_app.py`), verified locally before anything else:
```bash
pip install -r requirements-dev.txt
pytest tests/ -v --cov=app --cov-report=term-missing
```
```
tests/test_app.py::test_home PASSED                                      [ 12%]
tests/test_app.py::test_health PASSED                                    [ 25%]
tests/test_app.py::test_status PASSED                                    [ 37%]
tests/test_app.py::test_add PASSED                                       [ 50%]
tests/test_app.py::test_add_missing_field PASSED                         [ 62%]
tests/test_app.py::test_calculate_multiply PASSED                        [ 75%]
tests/test_app.py::test_calculate_divide_by_zero PASSED                  [ 87%]
tests/test_app.py::test_calculate_unknown_operation PASSED               [100%]
8 passed in 1.15s
```

## SAST — Bandit

Ran it, and it found a **real** issue — didn't go looking for a contrived example:
```bash
bandit -r app/
```
```
>> Issue: [B104:hardcoded_bind_all_interfaces] Possible binding to all interfaces.
   Severity: Medium   Confidence: Medium
   Location: app/app.py:63:17
    app.run(host="0.0.0.0", port=5001)
```
This is real, but also a known, common false-positive shape for containerized apps: binding to `0.0.0.0` inside a container is *required* for the app to be reachable from outside it — Docker's own port mapping (`-p 5001:5001`) is what actually controls external exposure, not the bind address inside the container. Rather than silently ignore it, suppressed it explicitly with a comment explaining why:
```python
# nosec B104 - binding to 0.0.0.0 is required for the app to be reachable
# from outside its Docker container; this isn't a real exposure risk here
# because the container itself is only published on the port we choose.
app.run(host="0.0.0.0", port=5001)  # nosec B104
```
Re-ran, clean:
```
Total issues (by severity):
    Medium: 0
Total potential issues skipped due to specifically being disabled (#nosec): 1
```
The "1 skipped" count is the point — it's an auditable, explained suppression, not a disabled scanner.

## SCA — pip-audit

**Environment note:** couldn't run this locally — `pip-audit` needs a venv, and this WSL environment doesn't have `python3-venv` installed (`apt install` needs `sudo`, same recurring gap as module 15). GitHub's `ubuntu-latest` runners have it out of the box, so this one only runs for real in CI — see Pipeline Execution below.

## Secret Scanning — Gitleaks

CI-only (`gitleaks/gitleaks-action@v2` needs the full git history, which only makes sense to scan post-push) — see Pipeline Execution below.

## Docker Build

```bash
docker build -t devsecops-demo:local .
```
Built clean. Ran it and hit the real endpoints:
```bash
docker run -d -p 5001:5001 devsecops-demo:local
curl -s http://localhost:5001/health
curl -s -X POST http://localhost:5001/api/add -H 'Content-Type: application/json' -d '{"a":10,"b":20}'
curl -s -X POST http://localhost:5001/api/calculate -H 'Content-Type: application/json' -d '{"a":6,"b":3,"operation":"multiply"}'
```
```
{"status":"healthy"}
{"result":30}
{"result":18}
```

## Container Image Scanning — Trivy

Installed as a user-local binary (same no-sudo pattern as Helm), then scanned the real built image:
```bash
trivy image --severity HIGH,CRITICAL --scanners vuln devsecops-demo:local
```
```
devsecops-demo:local (debian 13.7)
Total: 44 (HIGH: 44, CRITICAL: 0)
```
44 real HIGH-severity CVEs, 0 CRITICAL — all in base OS packages inherited from `python:3.12-slim` (things like `util-linux`, `perl-base`, `ncurses`), not in application code. This is normal for any Debian-based image on any given day; the base image maintainers patch these on their own schedule.

## Security Gate

Given the above, gating on "zero HIGH" would make the pipeline permanently red for reasons outside this app's control. Gated on **CRITICAL only** instead — a realistic policy: block anything severe enough to demand an immediate stop, don't block on the constant background noise of upstream OS packages. `exit-code: 1` on `severity: CRITICAL` in the Trivy Action step below; since this image currently has 0 CRITICAL findings, the gate passes and the pipeline proceeds to push.

## Pipeline execution

*(pending — needs a real `git push`, which also publishes a container image to `ghcr.io/ujjwaljain16/devops-labs-devsecops-demo` — asked before doing that, same as module 15.)*

## Kubernetes deployment

*(pending — done manually against the live Minikube cluster once the image is on GHCR; see [ques.md](ques.md) §3 for why this isn't a CI job.)*

## Screenshots

*(pending)*
