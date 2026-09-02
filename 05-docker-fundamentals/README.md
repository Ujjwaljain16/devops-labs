# Docker Fundamentals - Hello World Multi-Stack Applications

**Student Name:** Ujjwal Jain  
**Roll Number:** 24bcs10173  
**Section:** Section B  
**Topic:** Containerizing 6 Different Tech Stacks with Docker  

---

## 📌 Project Overview
This laboratory demonstrates building, containerizing, and running 6 distinct Hello World web applications across different runtime ecosystems:
1. **`nodejs-app`** (Node.js / Express on port `3000`)
2. **`python-app`** (Python / Flask on port `5000`)
3. **`java-app`** (Java / Built-in HTTP Server on port `8080`)
4. **`Apache-app`** (Apache HTTP Server on port `80`)
5. **`React-app`** (React Single Page App on port `80`)
6. **`nginx-app`** (Nginx Web Server on port `80`)

---

## 📁 Repository Structure
```text
05-docker-fundamentals/
├── Apache-app/
│   ├── Dockerfile
│   └── index.html
├── java-app/
│   ├── App.java
│   └── Dockerfile
├── nginx-app/
│   ├── Dockerfile
│   └── index.html
├── nodejs-app/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── python-app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── React-app/
│   ├── Dockerfile
│   └── index.html
└── README.md
```

---

## 🚀 Build, Run & Verification Matrix

| Application | Build Command | Run Command | Access URL |
| :--- | :--- | :--- | :--- |
| **Node.js** | `docker build -t devops-nodejs ./nodejs-app` | `docker run -d -p 3000:3000 --name nodejs-container devops-nodejs` | `http://localhost:3000` |
| **Python** | `docker build -t devops-python ./python-app` | `docker run -d -p 5000:5000 --name python-container devops-python` | `http://localhost:5000` |
| **Java** | `docker build -t devops-java ./java-app` | `docker run -d -p 8080:8080 --name java-container devops-java` | `http://localhost:8080` |
| **Apache** | `docker build -t devops-apache ./Apache-app` | `docker run -d -p 8081:80 --name apache-container devops-apache` | `http://localhost:8081` |
| **React** | `docker build -t devops-react ./React-app` | `docker run -d -p 8082:80 --name react-container devops-react` | `http://localhost:8082` |
| **Nginx** | `docker build -t devops-nginx ./nginx-app` | `docker run -d -p 8083:80 --name nginx-container devops-nginx` | `http://localhost:8083` |

---

## 🖥️ Verification Outputs

### 1. Checking Active Containers
```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```

**Output:**
```text
NAMES               IMAGE            STATUS         PORTS
nodejs-container    devops-nodejs    Up 2 minutes   0.0.0.0:3000->3000/tcp
python-container    devops-python    Up 2 minutes   0.0.0.0:5000->5000/tcp
java-container      devops-java      Up 2 minutes   0.0.0.0:8080->8080/tcp
apache-container    devops-apache    Up 2 minutes   0.0.0.0:8081->80/tcp
react-container     devops-react     Up 2 minutes   0.0.0.0:8082->80/tcp
nginx-container     devops-nginx     Up 2 minutes   0.0.0.0:8083->80/tcp
```

### 2. Probing Endpoints via `curl`
```bash
# Node.js
curl -s http://localhost:3000 | grep -o "Hello World from Node.js[^<]*"
# Output: Hello World from Node.js Web Application! 🚀

# Python Flask
curl -s http://localhost:5000 | grep -o "Hello World from Python[^<]*"
# Output: Hello World from Python Flask! 🐍

# Java
curl -s http://localhost:8080 | grep -o "Hello World from Java[^<]*"
# Output: Hello World from Java Web Application! ☕

# Apache
curl -s http://localhost:8081 | grep -o "Hello World from Apache[^<]*"
# Output: Hello World from Apache Web Server! 🪶

# React
curl -s http://localhost:8082 | grep -o "Hello World from React[^<]*"
# Output: Hello World from React Application! ⚛️

# Nginx
curl -s http://localhost:8083 | grep -o "Hello World from Nginx[^<]*"
# Output: Hello World from Nginx Web Server! 🟢
```
