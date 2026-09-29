# DevOps Engineering Laboratory - Section B Submissions

**Student Name:** Ujjwal Jain  
**Email:** [ujjwal.24bcs10173@sst.scaler.com](mailto:ujjwal.24bcs10173@sst.scaler.com)  
**Enrollment No.:** 24bcs10173  
**Section:** Section B  
**Repository:** [devops-labs](https://github.com/Ujjwaljain16/devops-labs)  

---

## 📌 Executive Summary & Submission Overview
This repository contains the complete laboratory implementations, source code, container configurations, shell scripts, and technical reports for all DevOps homework modules, from Linux fundamentals through Docker and into Kubernetes.

---

## 📂 Laboratory Modules Index

```text
.
├── .github/workflows/                   # module15-converter-cicd.yml, module16-devsecops.yml (must live at repo root)
├── 01-linux-fundamentals/
│   └── README.md                       # Soft/Hard links, adduser vs useradd, journalctl, command cheat sheet
├── 02-shell-scripting/
│   ├── sysinfo.sh                      # System info script with user prompts, mkdir, touch, > redirection
│   └── README.md                       # Shell script documentation & output logs
├── 03-networking-fundamentals/
│   └── README.md                       # ping, traceroute, curl, nslookup, dig, ss/netstat, ip a
├── 04-git-and-github/
│   └── README.md                       # git commit -a -m vs -m, git cherry-pick step-by-step
├── 05-docker-fundamentals/
│   ├── Apache-app/                     # Apache HTTPD containerized Hello World (Port 80/8081)
│   ├── java-app/                       # Java OpenJDK containerized Hello World (Port 8080)
│   ├── nginx-app/                      # Nginx containerized Hello World (Port 80/8083)
│   ├── nodejs-app/                     # Node.js + Express containerized Hello World (Port 3000)
│   ├── python-app/                     # Python + Flask containerized Hello World (Port 5000)
│   ├── React-app/                      # React SPA containerized with Nginx (Port 80/8082)
│   └── README.md                       # Full multi-stack build and run matrix
├── 06-docker-multistage-images/
│   ├── Dockerfile                      # Ultra-lean multi-stage Go builder -> Alpine runtime (~12MB)
│   ├── main.go                         # "Hello World from Docker multi-stage build" server (Port 8080)
│   └── README.md                       # Verification report, docker ps evidence & 3-stack deployment docs
├── 07-docker-networking-and-volumes/
│   ├── html/
│   │   └── index.html                  # Bind mount source file for live hot-reload
│   ├── compose-demo/                   # docker-compose.yml: frontend/backend/db stack, backend built from local Dockerfile
│   ├── ques.md                         # Assignment breakdown: what Tasks 1-4 already covered vs. Tasks 5-7 added later
│   └── README.md                       # Multi-network isolation, host net, bind mounts, VXLAN overlay, multi-network docker inspect, named volumes, Compose
├── 08-kubernetes-fundamentals/
│   ├── ques.md                         # Assignment breakdown: required vs optional homework
│   └── README.md                       # K8s architecture doc review, Minikube install/start/status, Hello Minikube deployment
├── 09-kubernetes-pods-replicasets-deployments/
│   ├── pod-lifecycle/                  # 12 manifests: running, pending, succeeded, failed, crashloop, image-pull, probes, init, sidecar, graceful termination
│   ├── replicaset/                     # yatri-backend-rs.yaml + scaling practice
│   ├── deployments/                    # deployment-v1.yaml / deployment-v2.yaml rolling update
│   ├── troubleshooting/                # selector-mismatch.yaml & broken-image.yaml controlled-failure demos
│   ├── resource-limits/                # cpu-throttle-pod.yaml & memory-oomkill-pod.yaml — real CPU throttling + OOMKilled demos
│   ├── ques.md                         # Assignment breakdown: explicit homework vs session practice
│   └── README.md                       # kubectl transcripts: pod-lifecycle+hello.yaml live watch, RS self-healing, rolling update, troubleshooting fix-and-recover, resource limits, theory writeup
├── 10-kubernetes-networking-and-services/
│   ├── pod.yaml                        # Hand-written Nginx Pod manifest (apiVersion/kind/metadata/spec)
│   ├── ques.md                         # Assignment breakdown: pod.yaml basics, apply vs create
│   └── README.md                       # apply vs create proof, port-forward verification, kubectl get sweep
├── 11-kubernetes-ingress-configmaps-secrets/
│   ├── 01-configmap/                   # app-config.yaml — declarative ConfigMap + JSONPath queries
│   ├── 02-secret/                      # db-secret.yaml — Opaque Secret, base64 decode, trailing-newline gotcha
│   ├── 03-ingress/                     # campus-apps + host-based Ingress + hybrid host/path/TLS Ingress
│   ├── 04-full-demo/                   # ConfigMap+Secret+backend+frontend+path-based Ingress, run-demo.sh / cleanup.sh
│   ├── ques.md                         # Assignment breakdown (Lecture 12 task list, 14 tasks)
│   └── README.md                       # ConfigMap live-update drill, Secret gotchas, NGINX Ingress, routing, TLS termination
├── 12-kubernetes-storage-hpa-probes/
│   ├── 01-kubernetes-volumes/           # emptyDir, hostPath, static PV/PVC, dynamic provisioning via StorageClass — all deployed & verified
│   ├── 02-hpa/                          # deployment.yaml, hpa.yml, load-generator.yaml — real scale-up 1->2->4->5 replicas captured
│   ├── ques.md                          # Assignment breakdown
│   ├── gaps.md                          # Open items needing info from Ujjwal: Task 3 Mini Project brief, Probes scope
│   └── README.md                        # HPA walkthrough: metrics-server setup, live polling log, kubectl describe hpa event history
├── 13-kubernetes-troubleshooting/
│   ├── manifests/                       # 7 broken/fixed manifest pairs — all 9 doc-listed failure states genuinely reproduced & fixed
│   ├── ques.md                          # Assignment breakdown
│   └── README.md                        # Full identify/investigate/root-cause/fix/verify report for every issue, plus Task 1's 8-command toolkit
├── 14-helm/
│   ├── myapp-chart/                     # Real chart (helm create + customized values.yaml), taken through install/upgrade x2/rollback
│   ├── ques.md                          # Assignment breakdown
│   └── README.md                        # All 11 helm commands + full install->upgrade->upgrade->rollback workflow, real revisions & verification
├── 15-cicd-github-actions/
│   ├── app/, tests/                     # Own unit-conversion app + pytest suite — verified locally (5 passed)
│   ├── Dockerfile                       # Verified locally (docker build + docker run)
│   ├── ques.md                          # Assignment breakdown + where "10-final-cicd-pipeline" actually came from
│   └── README.md                        # Real pushed pipeline (3 live Actions runs incl. a genuine break-then-fix cycle)
├── 16-cicd-devsecops/
│   ├── app/, tests/                     # Own Flask app + pytest suite — verified locally (8 passed)
│   ├── Dockerfile, k8s/                 # Verified locally; k8s manifests for manual Minikube deploy (CI can't reach it)
│   ├── ques.md                          # Assignment breakdown, tool substitutions, why deploy is manual not CI
│   └── README.md                        # Bandit/Trivy real findings + fixes, pipeline run pending a git push (needs go-ahead)
├── 17-terraform-infrastructure-as-code/ # TODO — Session 18: Terraform S3 demo (needs AWS)
├── 18-cloud-terraform-in-action/        # TODO — Session 19: end-to-end Terraform cloud infra (needs AWS)
├── 19-monitoring-observability-gitops/  # TODO — Session 20: Monitoring, Observability, GitOps
├── 20-final-devops-project/             # TODO — Session 21: Final capstone project
├── extra-kubernetes-workloads-rollback-and-dns/  # Bonus, not part of the doc's 20-module list
│   ├── deployment/                     # v1-v4 Deployment manifests (nginx 1.24 -> 1.27), 4-revision rollout history
│   ├── daemonset-demo/                 # node-agent-demo DaemonSet, one Pod per node proof
│   ├── statefulset-demo/               # headless-service.yaml + statefulset.yaml — 3-replica MySQL, ordinal identity, PVC-per-ordinal proof
│   ├── dns-test/                       # curl-test-pod.yaml for hands-on FQDN/CoreDNS resolution proof
│   ├── ques.md                         # Assignment breakdown: StatefulSet/DaemonSet homework vs already-covered ReplicaSet/Deployment
│   └── README.md                       # Rollback V4->V1, DNS/CoreDNS resolution proof, live StatefulSet deploy + identity-invariance vs Deployment
├── extra-deployment-strategies/         # Bonus, not part of the doc's 20-module list
│   ├── 02-blue-green/                  # deployment-blue/green.yaml + service-blue/green.yaml — instant cutover & rollback
│   ├── 03-canary/                      # deployment-stable(9)/canary(1).yaml + service.yaml — real traffic-ratio testing
│   ├── 04-recreate/                    # deployment-v1/v2.yaml, strategy.type Recreate — live-captured downtime window
│   ├── ques.md                         # Assignment breakdown: gap-filled from repo audit against Lecture 10 Tasks 11-13
│   └── README.md                       # Blue-Green cutover, canary traffic-split (incl. port-forward gotcha), recreate outage capture
└── README.md                           # Master submission guide
```

---