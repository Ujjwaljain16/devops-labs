# DevOps Engineering Laboratory - Section B Submissions

**Student Name:** Ujjwal Jain  
**Email:** [ujjwal.24bcs10173@sst.scaler.com](mailto:ujjwal.24bcs10173@sst.scaler.com)  
**Enrollment No.:** 24bcs10173  
**Section:** Section B  
**Repository:** [devops-labs](https://github.com/Ujjwaljain16/devops-labs)  

---

## 📌 Executive Summary & Submission Overview
This repository contains the complete laboratory implementations, source code, container configurations, shell scripts, and technical reports for all DevOps homework modules, from Linux fundamentals through Docker and into Kubernetes.

All tasks have been organized into feature folders with humanized, student-crafted documentation, practical examples, architecture diagrams, and terminal execution outputs.

---

## 📂 Laboratory Modules Index

```text
.
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
│   └── README.md                       # Multi-network container isolation, host net, bind mounts & VXLAN overlay
├── 08-kubernetes-pods-replicasets-deployments/
│   ├── ques.md                         # Assignment breakdown: required vs optional homework
│   └── README.md                       # K8s architecture doc review, Minikube install/start/status, Hello Minikube deployment
├── 09-kubernetes-ingress-configmaps-secrets/  # named per official session title; actual content is Pod lifecycle/ReplicaSets/Deployments/resource-limits (see ques.md for the title/content mismatch note)
│   ├── pod-lifecycle/                  # 12 manifests: running, pending, succeeded, failed, crashloop, image-pull, probes, init, sidecar, graceful termination
│   ├── replicaset/                     # yatri-backend-rs.yaml + scaling practice
│   ├── deployments/                    # deployment-v1.yaml / deployment-v2.yaml rolling update
│   ├── troubleshooting/                # selector-mismatch.yaml & broken-image.yaml controlled-failure demos
│   ├── resource-limits/                # cpu-throttle-pod.yaml & memory-oomkill-pod.yaml — real CPU throttling + OOMKilled demos
│   ├── ques.md                         # Assignment breakdown: explicit homework vs session practice
│   └── README.md                       # Full kubectl apply/describe/logs/scale transcripts against live Minikube cluster
├── 10-kubernetes-networking-and-services/
│   ├── pod.yaml                        # Hand-written Nginx Pod manifest (apiVersion/kind/metadata/spec)
│   ├── ques.md                         # Assignment breakdown: pod.yaml basics, apply vs create
│   └── README.md                       # apply vs create proof, port-forward verification, kubectl get sweep
├── 11-kubernetes-workloads-rollback-and-dns/
│   ├── deployment/                     # v1-v4 Deployment manifests (nginx 1.24 -> 1.27), 4-revision rollout history
│   ├── daemonset-demo/                 # node-agent-demo DaemonSet, one Pod per node proof
│   ├── dns-test/                       # curl-test-pod.yaml for hands-on FQDN/CoreDNS resolution proof
│   ├── ques.md                         # Assignment breakdown: StatefulSet/DaemonSet homework vs already-covered ReplicaSet/Deployment
│   └── README.md                       # Rollback V4->V1, DNS/CoreDNS resolution proof, StatefulSet/DaemonSet comparison
└── README.md                           # Master submission guide
```

---

## ⚡ Quick Start: Running the Labs

```bash
# Clone the repository
git clone https://github.com/Ujjwaljain16/devops-labs.git
cd devops-labs

# 1. Run the Shell Script
chmod +x 02-shell-scripting/sysinfo.sh
./02-shell-scripting/sysinfo.sh

# 2. Build & Run the Multi-Stage Docker App
cd 06-docker-multistage-images
docker build -t devops-multistage-app:v1.0 .
docker run -d -p 8080:8080 --name multistage-demo devops-multistage-app:v1.0
curl http://localhost:8080
```
