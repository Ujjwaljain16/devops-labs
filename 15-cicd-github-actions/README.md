# CI/CD & GitHub Actions

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for the exact task and where the `10-final-cicd-pipeline` reference actually came from (the instructor's own template repo, not something attached to the doc).

**Environment note:** this module needed `pip` and Python test tooling, neither of which were installed in WSL, and `apt install python3-venv`/`python3-pip` needs `sudo` (a password prompt I can't answer). Bootstrapped `pip` into the user's own site-packages instead — no root, no system packages touched:
```bash
curl -sSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python3 /tmp/get-pip.py --user --break-system-packages
```

---

## CI vs CD

**CI (Continuous Integration):** every push automatically builds the app and runs its tests, so broken code is caught within minutes of being written, not discovered later. That's the `test` and `security-check` jobs below.

**CD (Continuous Delivery/Deployment):** once CI passes, the app is packaged into something deployable — here, a Docker image — and made ready to ship. The reference project this task points to (see [ques.md](ques.md) §2) explicitly stops at "ready for CD / deployment" and says actual deployment targets (Docker registry push, Kubernetes, a cloud provider) are the *next* session's material. So "CD" in this module means: **the pipeline produces a real, working Docker image as its output** — the deploy-it-somewhere step is module 16 (DevSecOps)'s job.

## Application

A small Python unit-conversion library (`app/converter.py`) — Celsius/Fahrenheit and km/miles, both directions:
```python
def celsius_to_fahrenheit(c: float) -> float:
    return (c * 9 / 5) + 32

def fahrenheit_to_celsius(f: float) -> float:
    return (f - 32) * 5 / 9
```

Verified locally before it ever touched CI:
```bash
python3 -m pytest -v
```
```
tests/test_converter.py::test_celsius_to_fahrenheit PASSED               [ 20%]
tests/test_converter.py::test_fahrenheit_to_celsius PASSED               [ 40%]
tests/test_converter.py::test_km_to_miles PASSED                         [ 60%]
tests/test_converter.py::test_miles_to_km PASSED                         [ 80%]
tests/test_converter.py::test_round_trip_celsius PASSED                  [100%]
5 passed in 0.45s
```

## Dockerfile

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ ./app/
CMD ["python", "app/converter.py"]
```

Built and run locally before wiring it into CI:
```bash
docker build -t converter-app:local .
docker run --rm converter-app:local
```
```
25C -> 77.0 F
10km -> 6.21 miles
```

## GitHub Actions workflow

File: [.github/workflows/module15-converter-cicd.yml](../.github/workflows/module15-converter-cicd.yml) — has to live at the **repository root**'s `.github/workflows/`, not inside this module folder; that's the one place GitHub Actions actually looks for workflow files. `defaults.run.working-directory` points every step at `15-cicd-github-actions/` so the workflow only touches this module.

**Workflow anatomy** (the concepts the doc asks for, mapped onto the real file):
- **Workflow** = the whole YAML file, triggered `on: push` to this folder (path-filtered so other modules' pushes don't trigger it) and `workflow_dispatch` for manual runs.
- **Jobs** = `test`, `security-check`, `build` — three independent units that can run in parallel unless one depends on another.
- **`needs: [test, security-check]`** on `build` — the actual CI gate: build only runs if both prior jobs succeed. This is the same mechanism the reference project uses to prove tests genuinely block a broken build (reproduced for real below).
- **Steps** = the ordered list inside each job (`Checkout` -> `Setup Python` -> `Install dependencies` -> `Run pytest`, etc.)
- **Runners** = `runs-on: ubuntu-latest` — GitHub's own hosted VM, fresh for every job.
- **Secrets** = `DEMO_SECRET`, a repository secret referenced as `${{ secrets.DEMO_SECRET }}` — GitHub auto-masks its value in every log line, which the `security-check` job's last step proves without ever printing it in the clear.
- **Artifacts** = `actions/upload-artifact@v4` — the `build` job's output (`converter.py` + `build-info.txt` with the commit SHA and build timestamp) gets attached to the run, downloadable from the Actions UI afterward.

## Pipeline execution

*(pending — needs a real `git push` to `Ujjwaljain16/devops-labs` to actually trigger. Everything above is verified locally; this section gets the real Actions run output once pushed.)*

## Break-it-then-fix-it (proves `needs: test` actually gates the build)

*(pending — same push dependency as above)*

## Screenshots

*(pending)*
