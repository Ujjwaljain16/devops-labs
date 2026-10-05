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

Each line says what exists. Items marked as open are real gaps against the doc, and I list them here instead of hiding them.

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
- [ ] ConfigMap: the chart passes its non-secret settings as plain environment variables and has no ConfigMap yet. I covered ConfigMaps in module 11, but the capstone does not use one.
- [ ] SCA for the Python dependencies: only the frontend is audited in the pipeline. I used `pip-audit` for this in module 16, and the capstone pipeline does not run it yet.
- [ ] Logs: the application writes to standard output and I used `kubectl logs` in the troubleshooting labs, but there is no log collection in the monitoring stack.
- [ ] GitOps: there is no Argo CD application and no `gitops/` folder in the capstone. I built a real Argo CD workflow in module 19, but it is not part of this project.
- [ ] README sections named by the doc: it has no section titled "Technologies used", "GitOps" or "Lessons learned" yet.
- [ ] The doc's exact folder names (`security/`, `gitops/`, `docker/`, `kubernetes/`) are not present as folders, because the repository is organised differently.
