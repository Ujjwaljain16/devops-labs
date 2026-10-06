# Assignment - Final DevOps Project & Troubleshooting

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Final DevOps Project & Troubleshooting (Session 21 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 21 tab, together with the instructor's reference repository and its `GRADING.md`

The project itself lives in its own repository, [Ujjwaljain16/campusslot](https://github.com/Ujjwaljain16/campusslot), and the commands, real output and screenshots are in its [README](https://github.com/Ujjwaljain16/campusslot/blob/main/README.md). The [README.md](README.md) in this folder is the short pointer and the map from the doc to that repository.

---

## 1. What the doc requires

The Session 21 tab asks for a complete end-to-end project: Application, Git, GitHub, CI pipeline, build and test, security scanning, Docker image, container registry, Kubernetes, Helm, monitoring and GitOps, with these parts:

- **Infrastructure:** Terraform provisions the required cloud infrastructure.
- **Kubernetes:** Deployment, Service, ConfigMap, Secret, Ingress, HPA, probes, and storage where required.
- **CI/CD:** GitHub Actions with build, test, Docker build, image push and a Kubernetes deployment.
- **DevSecOps:** SAST, SCA, secret scanning, container image scanning and security gates.
- **Monitoring and GitOps:** monitoring, logs and metrics, and a GitOps workflow.
- **Final troubleshooting challenge:** intentionally introduce several issues, then identify, investigate, find the root cause, fix, verify and document each one.
- **Deliverables:** a `final-devops-project/` folder with `application`, `docker`, `kubernetes`, `helm`, `terraform`, `.github/workflows`, `security`, `monitoring`, `gitops` and a `README.md` that covers the overview, architecture diagram, technologies used, application setup, Docker, Kubernetes, Helm, Terraform, CI/CD, DevSecOps, monitoring, GitOps, troubleshooting, screenshots and lessons learned.

## 2. Notes

I used an original domain, campus room and lab booking, because the instructor's reference repository states in its grading policy that a clone of its own TaskBoard application receives zero. Where the doc and the reference repository's `GRADING.md` differ, I followed `GRADING.md` for the marks and the doc for the intent. The most important difference is that the doc mentions only that Terraform must provision cloud infrastructure, while `GRADING.md` awards points for a real VPC and EKS cluster, a plan and a destroy. I therefore applied the Terraform to a real AWS account and destroyed it again.

I built the project as a separate public repository, not as a folder inside this one, because it has its own CI pipeline, container registry packages and Helm chart, and a pipeline must live at the root of the repository that it builds. This folder holds only the pointer.

The folder layout in the doc is a suggestion for a single folder, and my repository uses different names because the application has a backend and a frontend. The table in [README.md](README.md) maps every folder of the doc to its place in the project.

## 3. My completion checklist

Each line says what exists. When I first compared the project with this list I found five gaps, and I closed all of them afterwards, so I keep the history here instead of hiding it.

- [x] Application, Git, GitHub: original FastAPI, React and PostgreSQL application, public repository, more than thirty meaningful commits
- [x] CI pipeline with build and test: pytest with a coverage floor, PostgreSQL integration tests, frontend tests and build
- [x] Docker image and registry: two non-root images pushed to GHCR, tagged with the commit SHA
- [x] Kubernetes: Deployments, Services, Secret, Ingress, HPA with a real scale up and down, probes, PostgreSQL storage on a PVC, namespace with the restricted Pod Security profile
- [x] Helm: a complete chart with values for development, CI and production
- [x] Terraform: VPC and EKS applied to a real account and destroyed, with the account verified empty afterwards
- [x] CI/CD: GitHub Actions with Docker build, image push and a Helm deployment to a kind cluster with a smoke test
- [x] DevSecOps: SAST (Bandit), secret scanning (Gitleaks), container image scanning (Trivy) with a gate on fixable HIGH and CRITICAL findings, and `npm audit` for the frontend dependencies
- [x] Monitoring: Prometheus and Grafana with a provisioned dashboard and live application metrics
- [x] Final troubleshooting challenge: four deliberate failures, each documented with identify, investigate, root cause, fix and verify
- [x] Screenshots and a README with real transcripts
- [x] ConfigMap: the non-secret settings are rendered into a ConfigMap and loaded with `envFrom`, and a checksum annotation restarts the pods when it changes. I proved the whole path through Git: a committed change of `LOG_LEVEL` reached the ConfigMap within 8 seconds and rolled the pods.
- [x] SCA for the Python dependencies: `pip-audit` runs as a pipeline gate next to `npm audit`, and it reports no known vulnerabilities in the pinned requirements.
- [x] Logs: the application writes structured JSON logs, Grafana Alloy collects them, Loki stores them, and Grafana shows a log stream and a conflicts-per-layer panel. After 105 deliberate double bookings Loki counted exactly 105 rejected-booking lines.
- [x] GitOps: an Argo CD Application keeps the cluster in line with `gitops/values.yaml`. I promoted a build by commit, changed the configuration by commit, and watched Argo CD undo a manual ConfigMap edit and a deleted Service within 4 seconds. The demonstration also found and fixed two real problems, a migration Job that cannot be patched and a sync that failed because the autoscaler had no metrics for a minute.
- [x] README sections named by the doc: the project README now has Technologies used, GitOps and Lessons learned.
- [x] The doc's folder names: `gitops/` and `security/` now exist in the project repository. The other folders of the doc map to `backend/` and `frontend/`, the Dockerfiles, `k8s/` and `helm/`, as the table in [README.md](README.md) shows.

I also re-ran the cleanup after the GitOps work: the local cluster was deleted again, no Docker leftovers of the project remain, and AWS was checked again and was empty.

## 4. Beyond the checklist

After the checklist was complete I spent the remaining time on the engineering habit behind it: measure, change one thing, measure again, and write down the trade-off. The results are in the project README under [Engineering decisions and results](https://github.com/Ujjwaljain16/campusslot#engineering-decisions-and-results). In short:

- **Pipeline and process:** DORA metrics from the real pipeline history, the pipeline median cut from 238 s to 148 s, branch protection with a proven rejected push, static analysis of the Terraform and the Helm chart, and signed image provenance verified before every deployment.
- **Reliability:** alert rules with a drill that fired and resolved, rollouts that lost requests before (8 of 8) and none after, a database outage that the alerts could not see until I fixed it, a deliberately broken release that Helm rolled back by itself in 72 s while none of 4800 user requests failed, and a backup that I restored with an identical checksum.
- **Scale and sizing:** with 200 thousand bookings, the overlap check read 2469 pages and now reads 30 (a range query and a GiST index). One pod went from 153 to 342 requests per second after I found it was throttled by its own CPU limit. Two other ideas (more worker processes and an ETag) did nothing, so I removed them. Sized from measurements, the same 60 requests per second needs 2 pods instead of 5.
- **Decisions:** fourteen short decision records.

The same README lists what I planned and chose not to do, such as a rollback drill, automated promotion and network policies.
