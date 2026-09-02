# Docker Networking & Storage Volumes Lab

**Name:** Ujjwal Jain  
**Topic:** Container Isolation, Custom Bridge Networks, Host Networking, Bind Mounts, and Swarm Overlay Architecture  

---

## 📌 Task 1: Docker Container Networking & Multi-Network Isolation

### 1. Architectural Design
To simulate a real-world multi-tier architecture, we establish network isolation between:
- **`frontend`** (Web interface)
- **`backend`** (API service)
- **`database`** (MySQL datastore)

```text
  [ Frontend Container ]
          │ (attached to frontend-net)
          ▼
    [ frontend-net ]
          ▲
          │ (attached to frontend-net)
  [ Backend Container ]
          │ (attached to db-net)
          ▼
      [ db-net ]
          ▲
          │ (attached to db-net)
  [ Database Container ]
```
> **Security Boundary:** `frontend` has NO access to `db-net` and cannot directly query or reach `database`. The `backend` acts as the secure intermediary bridging both networks.

---

### 2. Execution Steps

#### Step A: Create 3 Custom User-Defined Bridge Networks
```bash
docker network create --driver bridge frontend-net
docker network create --driver bridge backend-net
docker network create --driver bridge db-net
```

#### Step B: Launch Containers
```bash
# 1. Launch Database on db-net
docker run -d --name database-container \
  --network db-net \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0

# 2. Launch Backend on frontend-net, then connect it to db-net
docker run -d --name backend-container \
  --network frontend-net \
  alpine sleep 3600

# Connect backend to second network (db-net)
docker network connect db-net backend-container

# 3. Launch Frontend on frontend-net
docker run -d --name frontend-container \
  --network frontend-net \
  nginx:alpine
```

---

### 3. Connectivity Verification

#### Test 1: Frontend reaching Backend (Should Succeed ✅)
```bash
docker exec -it frontend-container ping -c 2 backend-container
```
**Output:**
```text
PING backend-container (172.19.0.3): 56 data bytes
64 bytes from 172.19.0.3: seq=0 ttl=64 time=0.082 ms
64 bytes from 172.19.0.3: seq=1 ttl=64 time=0.075 ms

--- backend-container ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
```

#### Test 2: Frontend reaching Database directly (Should Fail ❌ - Isolation Preserved)
```bash
docker exec -it frontend-container ping -c 2 database-container
```
**Output:**
```text
ping: bad address 'database-container'
```
> *Observation:* DNS resolution and packet routing fail because `frontend-container` is not part of `db-net`. This prevents direct database exploitation.

#### Test 3: Backend reaching Database (Should Succeed ✅)
```bash
docker exec -it backend-container ping -c 2 database-container
```
**Output:**
```text
PING database-container (172.21.0.2): 56 data bytes
64 bytes from 172.21.0.2: seq=0 ttl=64 time=0.091 ms
64 bytes from 172.21.0.2: seq=1 ttl=64 time=0.079 ms

--- database-container ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
```

---

## 📌 Task 2: Host Network Mode (`--network host`)

### 1. Conceptual Breakdown
When using `--network host`, the container skips Docker's network namespace isolation and shares the host machine’s network stack directly. Container ports are mapped directly to host ports with zero NAT (Network Address Translation) latency overhead.

### 2. Execution & Testing
```bash
# Pull Apache2 image
docker pull httpd:2.4-alpine

# Run container on the host network
docker run -d --name apache-host-container --network host httpd:2.4-alpine
```

### 3. Verification
```bash
# Check listening port on host directly
curl -I http://localhost:80
```
**Output:**
```text
HTTP/1.1 200 OK
Date: Wed, 02 Sep 2026 13:48:10 GMT
Server: Apache/2.4.58 (Unix)
Content-Type: text/html
```
> *Observation:* No `-p 80:80` port forwarding was specified; Apache directly bound to port `80` on the host network interface.

---

## 📌 Task 3: Bind Mounts (Live Hot-Reloading)

### 1. What is a Bind Mount?
A bind mount maps an exact directory or file from the host filesystem directly into the container filesystem. Any changes made to the host files are instantly visible inside the container without rebuilding the Docker image or restarting the container.

---

### 2. Step-by-Step Execution

#### Step A: Create Local HTML Folder & File
```bash
mkdir -p ./html
echo "<h1>Hello students</h1>" > ./html/index.html
```

#### Step B: Start Nginx Container with Bind Mount
```bash
docker run -d --name nginx-bind-container \
  -p 8085:80 \
  -v "$(pwd)/html:/usr/share/nginx/html:ro" \
  nginx:alpine
```

#### Step C: Verify Initial Content
```bash
curl http://localhost:8085
```
**Output:**
```html
<h1>Hello students</h1>
```

#### Step D: Modify Local File on Host
```bash
echo "<h1>Hello students - Updated live at $(date)</h1>" > ./html/index.html
```

#### Step E: Verify Dynamic Hot-Reload (Without Container Restart!)
```bash
curl http://localhost:8085
```
**Output:**
```html
<h1>Hello students - Updated live at Wed Sep  2 13:48:22 UTC 2026</h1>
```
> *Result:* The content updated immediately in real time, proving that the container reads directly from the host filesystem mount.

---

## 📌 Task 4: Docker Overlay Networks Deep Dive

### 1. What is an Overlay Network?
An **Overlay Network** creates a distributed virtual software network spanning multiple physical or virtual Docker host nodes in a **Docker Swarm** or Kubernetes cluster.

### 2. Internal Mechanism (VXLAN Encapsulation)
- Containers on Host A communicate with containers on Host B as if they were residing on the same local subnet.
- The underlying engine uses **VXLAN (Virtual Extensible LAN)** encapsulation (UDP port `4789`).
- When Container 1 sends an Ethernet frame, the Docker daemon wraps the frame inside a standard UDP packet, transmits it across the physical network to Host B, where Host B decapsulates the packet and delivers the original frame to Container 2.

```text
[ Container A (10.0.0.2) ]                      [ Container B (10.0.0.3) ]
         │                                               ▲
         ▼                                               │
 [ VXLAN Tunnel Endpoint ]                      [ VXLAN Tunnel Endpoint ]
         │ (Encapsulates into UDP:4789)                  ▲ (Decapsulates)
         ▼                                               │
   [ Docker Host 1 ] ═══════ Physical Network ═══════ [ Docker Host 2 ]
```

### 3. Key Use Cases
- **Multi-Host Microservice Communication:** Connecting frontends and backends deployed on disparate cloud servers without exposing backend ports to the public internet.
- **Service Discovery & Routing Mesh:** Automatic load balancing across replicated swarm tasks.
- **Encrypted Control & Data Plane:** Overlay networks can enforce end-to-end IPsec encryption (`--opt encrypted`) across host boundaries.
