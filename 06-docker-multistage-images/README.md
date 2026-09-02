# Docker Multi-Stage Build & Application Deployment Lab

**Student Name:** Ujjwal Jain  
**Enrollment Number:** 24bcs10173  
**Topic:** Docker Multi-Stage Builds, Image Optimization, and Multi-Stack Deployments  

---

## 📌 Task 1 & 2: Multi-Stage Dockerfile Execution & Verification

### 1. Conceptual Value of Multi-Stage Builds
In traditional single-stage Docker builds, compilers, build toolchains (SDKs, header files, linters), and intermediate files linger in the final container image, causing:
- Bloated image sizes (often > 800MB - 1GB).
- Increased security attack surface (unnecessary utilities like `gcc`, package managers, etc.).
- Slow pull/push times in CI/CD pipelines.

With **Multi-Stage Builds**, we separate the compilation environment from the final runtime image, resulting in image sizes dropping from hundreds of megabytes down to ~15MB.

---

### 2. Multi-Stage Dockerfile Breakdown
```dockerfile
# Stage 1: Build Stage (Heavy Go Toolchain)
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server main.go

# Stage 2: Final Production Runtime (Lean Alpine)
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]
```

---

### 3. Step-by-Step Execution Commands

```bash
# Navigate to directory
cd 06-docker-multistage-images

# 1. Build the multi-stage Docker image
docker build -t devops-multistage-app:v1.0 .

# 2. Run the container on port 8080
docker run -d -p 8080:8080 --name multistage-container devops-multistage-app:v1.0
```

---

### 4. Verification Evidence & Outputs

#### A. Checking Container Status (`docker ps`)
```bash
docker ps --filter "name=multistage-container"
```

**Terminal Output:**
```text
CONTAINER ID   IMAGE                         COMMAND       CREATED          STATUS          PORTS                    NAMES
a491bc04821e   devops-multistage-app:v1.0    "./server"    45 seconds ago   Up 44 seconds   0.0.0.0:8080->8080/tcp   multistage-container
```

#### B. Accessing & Verifying the Application Output
```bash
# Probing localhost on port 8080
curl -i http://localhost:8080
```

**Terminal Output:**
```text
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Date: Wed, 02 Sep 2026 13:47:45 GMT
Content-Length: 1420

<!DOCTYPE html>
<html lang="en">
...
        <h1>Hello World from Docker multi-stage build</h1>
        <p>DevOps Engineering Lab - Multi-Stage Optimization</p>
        <span class="badge">Listening on Port 8080 | Ultra-lean Container</span>
...
</html>
```

#### C. Image Size Comparison (`docker images`)
```bash
docker images | grep -E "devops-multistage-app|golang"
```

**Terminal Output:**
```text
REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
devops-multistage-app    v1.0      3fa8192c7102   2 minutes ago    12.4MB
golang                   1.22      9f82181bc701   2 weeks ago      302MB
```
> *Result:* The final production image is only **12.4 MB**, cutting down over **95%** of unnecessary image weight.

---

## 📌 Task 3: Docker Application Deployment (3 Different Stacks)

We deployed 3 distinct application architectures using Docker containerization:

### 1. Node.js Application Deployment
- **Base Image:** `node:18-alpine`
- **Port:** `3000`
- **Runtime Environment:** V8 JavaScript Engine with Express framework.
- **Key Characteristics:** Single-threaded asynchronous event loop, fast I/O handling, packaged with `npm` dependency isolation.
- **Verification:**
  ```bash
  curl http://localhost:3000
  # Displays: Hello World from Node.js Web Application! 🚀
  ```

### 2. Python Application Deployment
- **Base Image:** `python:3.11-slim`
- **Port:** `5000`
- **Runtime Environment:** Python WSGI with Flask framework.
- **Key Characteristics:** Lightweight web service, minimal dependencies managed via `pip` and `requirements.txt`.
- **Verification:**
  ```bash
  curl http://localhost:5000
  # Displays: Hello World from Python Flask! 🐍
  ```

### 3. Java Application Deployment
- **Base Image:** `openjdk:17-jdk-alpine`
- **Port:** `8080`
- **Runtime Environment:** Java Virtual Machine (JVM).
- **Key Characteristics:** Compiled bytecode architecture, robust memory management, containerized with multi-stage compilation.
- **Verification:**
  ```bash
  curl http://localhost:8080
  # Displays: Hello World from Java Web Application! ☕
  ```
