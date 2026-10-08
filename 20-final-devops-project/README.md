# Final DevOps Project: CampusSlot

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

**Project repository:** [Ujjwaljain16/campusslot](https://github.com/Ujjwaljain16/campusslot)
**Project README (the one to read):** [campusslot/README.md](https://github.com/Ujjwaljain16/campusslot/blob/main/README.md)

The exact task breakdown, the way I reconciled the homework doc with the instructor's grading file, and an honest checklist with the open items are in [ques.md](ques.md).

**This folder holds two separate things for Session 21:**

1. **My final project, CampusSlot** (below): an original application with its own repository. This is the capstone.
2. **[`taskboard-compose/`](taskboard-compose/README.md)**: the separate Session 21 homework on the **instructor's TaskBoard reference app**. I ran it by hand, built its Dockerfiles, brought it up with Docker Compose and tested the API and UI, with real outputs and the problems I found along the way. The application code there is the instructor's, unchanged, and is not presented as my project.

---

## What I built

CampusSlot is a room and lab booking service that guarantees that two confirmed bookings never overlap in the same room. I protect that rule in three layers (request validation, an application check and a PostgreSQL exclusion constraint), and I tested each layer. Around this small application I built the whole delivery chain:

- **Application:** FastAPI backend, React frontend, PostgreSQL with Alembic migrations.
- **Tests:** 46 backend tests, 4 PostgreSQL integration tests and 12 frontend tests, with a coverage floor of 85 percent.
- **Docker:** two multi-stage, non-root images, and a Compose stack with a persistent volume that I proved with a `down` and `up` cycle.
- **CI/CD:** GitHub Actions with tests, secret scan, image build, Trivy gate, push to GHCR with commit SHA tags, and a Helm deployment to a kind cluster with a smoke test.
- **Kubernetes and Helm:** a chart deployed on Minikube with ingress, a migration Job, an HPA that I watched scale from 2 to 5 replicas and back, and a restricted pod security namespace.
- **Terraform:** a VPC and an EKS cluster, applied to a real AWS account and destroyed about 45 minutes later. A final check found nothing left in the region.
- **Monitoring and logs:** Prometheus, Grafana and Loki with a provisioned dashboard built from the application's own metrics and its structured JSON logs.
- **GitOps:** Argo CD applies the desired state committed in `gitops/` and corrects manual drift within seconds.
- **Configuration and security gates:** a ConfigMap for the settings and a Secret for the password, and Bandit, `pip-audit`, `npm audit`, Gitleaks and Trivy as pipeline gates.
- **Troubleshooting:** four failures that I created on purpose and fixed.

## Where the doc's deliverables are

| Doc deliverable | Where it is in the project repository |
|---|---|
| `application/` | `backend/` and `frontend/` |
| `docker/` | `backend/Dockerfile`, `frontend/Dockerfile`, `docker-compose.yml` |
| `kubernetes/` | `k8s/namespace.yaml` and the templates of `helm/campusslot/` |
| `helm/` | `helm/campusslot/` |
| `terraform/` | `terraform/` |
| `.github/workflows/` | `.github/workflows/ci-cd.yml` |
| `security/` | `security/` (what each gate checks and how to run it), with the gates themselves as jobs in the workflow and the results in `docs/evidence/` |
| `monitoring/` | `monitoring/` |
| `gitops/` | `gitops/` (the Argo CD Application, the desired state and the Argo CD values) |
| Final troubleshooting challenge | `troubleshooting/` |
| Screenshots | `docs/evidence/` |

## Gaps that I found and closed

I compared the project with the doc's Session 21 list line by line and found five gaps: no ConfigMap in the chart, no Python dependency scan, no log collection, no GitOps workflow, and missing README sections. I covered each of these in an earlier module (11, 16 and 19), but I had not integrated them into this project. I closed all five, and [ques.md](ques.md) records what I built and how I proved each one.

## Evidence

All screenshots and transcripts are in [`docs/evidence`](https://github.com/Ujjwaljain16/campusslot/tree/main/docs/evidence) of the project repository, and the project README embeds the important ones: the green pipeline, the SHA tagged images in GHCR, both Trivy reports, the Prometheus targets, the Grafana dashboard, the Kubernetes and Helm output, and the AWS console with the EKS cluster and VPC.
