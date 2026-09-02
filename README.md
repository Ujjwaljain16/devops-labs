# DevOps Engineering Laboratory - Section B Submissions

**Student Name:** Ujjwal Jain  
**Email:** [ujjwal.24bcs10173@sst.scaler.com](mailto:ujjwal.24bcs10173@sst.scaler.com)  
**Enrollment No.:** 24bcs10173  
**Section:** Section B  
**Repository:** [devops-labs](https://github.com/Ujjwaljain16/devops-labs)  

---

## 📌 Executive Summary & Submission Overview
This repository contains the complete laboratory implementations, source code, container configurations, shell scripts, and technical reports for all DevOps homework modules up to Docker.

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
