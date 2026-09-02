# Docker Networking & Storage Volumes Lab

**Student Name:** Ujjwal Jain  
**Roll Number:** 24bcs10173  
**Section:** Section B  
**Topic:** Container Isolation, Custom Bridge Networks, Host Networking, Bind Mounts, and Swarm Overlay Architecture  
**Reference:** [devops-heros / session8-docker-networking-volume](https://github.com/Nency-Ravaliya/devops-heros/tree/main/session8-docker-networking-volume)

---

## 📌 Task 1: Docker Container Networking & Multi-Network Isolation

### 1. Architecture & Design Goal
To simulate a secure 3-tier enterprise architecture, we establish custom bridge networks such that:
- `lab-frontend` can communicate with `lab-backend`.
- `lab-backend` can communicate with `lab-db`.
- `lab-frontend` is **strictly isolated** from `lab-db` (cannot ping or query database directly).

```text
  [ lab-frontend ]
         │ (connected to lab-frontend-net)
         ▼
  [ lab-frontend-net ]
         ▲
         │ (connected to lab-frontend-net)
  [ lab-backend ]
         │ (connected to lab-db-net)
         ▼
    [ lab-db-net ]
         ▲
         │ (connected to lab-db-net)
    [ lab-db ] (MySQL 8.0)
```

---

### 2. Live Command Execution

#### Step A: Create Custom Bridge Networks
```bash
docker network create --driver bridge lab-frontend-net
docker network create --driver bridge lab-backend-net
docker network create --driver bridge lab-db-net
```

#### Step B: Start Containers & Multi-Network Connection
```bash
# 1. Start Database on lab-db-net
docker run -d --name lab-db --network lab-db-net -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

# 2. Start Backend on lab-frontend-net, then connect to lab-db-net
docker run -d --name lab-backend --network lab-frontend-net alpine sleep 3600
docker network connect lab-db-net lab-backend

# 3. Start Frontend on lab-frontend-net
docker run -d --name lab-frontend --network lab-frontend-net nginx:alpine
```

---

### 3. Verified Terminal Connectivity Outputs

#### Test 1: Frontend -> Backend (`lab-frontend` -> `lab-backend`)
```bash
docker exec lab-frontend ping -c 2 lab-backend
```
**Output:**
```text
PING lab-backend (172.19.0.2): 56 data bytes
64 bytes from 172.19.0.2: seq=0 ttl=64 time=0.059 ms
64 bytes from 172.19.0.2: seq=1 ttl=64 time=0.065 ms

--- lab-backend ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.059/0.062/0.065 ms
```
> **Result:** ✅ Successful (0% packet loss). Frontend communicates with Backend API.

---

#### Test 2: Frontend -> Database (`lab-frontend` -> `lab-db`)
```bash
docker exec lab-frontend ping -c 2 lab-db
```
**Output:**
```text
ping: bad address 'lab-db'
```
> **Result:** 🛡️ **Blocked / Isolated as designed**. Docker embedded DNS and network namespaces prevent the frontend from discovering or reaching the database subnet.

---

#### Test 3: Backend -> Database (`lab-backend` -> `lab-db`)
```bash
docker exec lab-backend ping -c 2 lab-db
```
**Output:**
```text
PING lab-db (172.21.0.2): 56 data bytes
64 bytes from 172.21.0.2: seq=0 ttl=64 time=0.070 ms
64 bytes from 172.21.0.2: seq=1 ttl=64 time=0.122 ms

--- lab-db ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.070/0.096/0.122 ms
```
> **Result:** ✅ Successful. Backend queries database securely over `lab-db-net`.

### 📷 Screenshot Verification (Network Isolation Test)
![Container Network Isolation Test](screenshots/01_container_network_test.png)

---

## 📌 Task 2: Host Network Mode (`--network host`)

### 1. Concept
In Host Network mode (`--network host`), the container bypasses Docker's virtual network stack and binds directly to the host's physical/virtual network interface, eliminating NAT latency.

### 2. Execution & Probing
```bash
# Run Apache on host network
docker run -d --name apache-host --network host httpd:2.4-alpine

# Probe host directly on port 80
curl -I http://localhost:80
```

**Terminal Output:**
```text
HTTP/1.1 200 OK
Date: Wed, 02 Sep 2026 20:26:50 GMT
Server: Apache/2.4.63 (Unix)
Content-Type: text/html
```

---

## 📌 Task 3: Bind Mounts (Live Hot-Reloading)

### 1. Concept
A bind mount mounts a local host directory into the container. Any edits on the host filesystem reflect inside the container instantaneously without rebuilding images or restarting containers.

---

### 2. Step-by-Step Live Verification

#### Step A: Initial Run with Bind Mount
```bash
docker run -d --name nginx-bind -p 8085:80 -v "${PWD}/html:/usr/share/nginx/html:ro" nginx:alpine
```

#### Step B: Initial Query (`curl http://localhost:8085`)
```bash
curl -s http://localhost:8085 | grep "<h1>"
```
**Output:**
```html
        <h1>Hello students</h1>
```

#### Step C: Live Edit Host File (`html/index.html`)
```bash
# Update text on host machine
sed -i 's/Hello students/Hello students - Live Hot Reload Verified! ⚡/' html/index.html
```

#### Step D: Instant Verification (No Container Restart!)
```bash
curl -s http://localhost:8085 | grep "<h1>"
```
**Output:**
```html
        <h1>Hello students - Live Hot Reload Verified! ⚡</h1>
```
> **Result:** Content updated dynamically in real time through the shared filesystem bind mount.

### 📷 Screenshot Verification (Bind Mount Hot-Reload)
![Bind Mount Hot Reload](screenshots/02_bind_mount_hot_reload.png)

---

## 📌 Task 4: Docker Overlay Networks Deep Dive

### 1. Overview & Multi-Host Networking
An **Overlay Network** enables containers running across physically distinct Docker hosts (nodes in a Docker Swarm or Kubernetes cluster) to communicate transparently on a private, routable Layer-2 virtual network.

### 2. How it Works (VXLAN Tunneling):
- Uses **VXLAN (Virtual Extensible LAN)** on UDP port `4789`.
- When Container A on Host 1 sends a packet to Container B on Host 2:
  1. The local Docker daemon wraps the Ethernet frame into a standard UDP packet.
  2. The packet travels over the underlying physical network.
  3. Host 2 decapsulates the UDP packet and delivers the original frame to Container B.
- This creates an encrypted, multi-host mesh without requiring complex physical routing modifications.

```text
[ Container A (10.0.0.2) ]                      [ Container B (10.0.0.3) ]
         │                                               ▲
         ▼                                               │
 [ VXLAN Tunnel Endpoint ]                      [ VXLAN Tunnel Endpoint ]
         │ (Encapsulate UDP:4789)                        ▲ (Decapsulate)
         ▼                                               │
   [ Docker Host 1 ] ═══════ Physical Underlay ══════ [ Docker Host 2 ]
```

### 3. Production Use Cases:
1. **Microservices in Docker Swarm / K8s:** Seamless service-to-service RPC across multiple worker nodes.
2. **Encrypted Traffic In Transit:** Automatic IPsec encryption between nodes with `--opt encrypted`.
3. **High-Availability Load Balancing:** Ingress routing mesh automatically distributes requests across replicas regardless of which node hosts the container.
