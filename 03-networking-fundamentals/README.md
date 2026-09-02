# Networking Fundamentals - Subnetting, IP Addressing & Command Analysis

**Student Name:** Ujjwal Jain  
**Roll Number:** 24bcs10173  
**Section:** Section B  
**Topic:** IPv4 Classes, Subnetting, Usable Hosts, Routing Inspection & Diagnostic Commands  
**Reference:** [devops-heros / session4-networking](https://github.com/Nency-Ravaliya/devops-heros/tree/main/session4-networking)

---

## 📌 Part 1: IP Addressing & Subnetting Theory

### 1. IPv4 Class Architecture

An IPv4 address consists of 32 bits divided into 4 octets (8 bits each), formatted in dotted-decimal notation (`X.X.X.X` ranging from `0.0.0.0` to `255.255.255.255`).

| Class | First Octet Range | Default Subnet Mask | Network Bits (N) | Host Bits (H) | Total Usable Hosts $(2^H - 2)$ | Primary Use Case |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Class A** | `1 - 127` | `255.0.0.0` (/8) | 8 | 24 | $2^{24} - 2 = 16,777,214$ | Huge global networks & ISPs |
| **Class B** | `128 - 191` | `255.255.0.0` (/16) | 16 | 16 | $2^{16} - 2 = 65,534$ | Medium to large enterprise networks |
| **Class C** | `192 - 223` | `255.255.255.0` (/24) | 24 | 8 | $2^8 - 2 = 254$ | Small LANs & home networks |
| **Class D** | `224 - 239` | N/A | N/A | N/A | N/A | Multicasting groups |
| **Class E** | `240 - 255` | N/A | N/A | N/A | N/A | Experimental & research |

> **Note:** The `- 2` subtraction in host calculations reserves:
> 1. **Network Address** (all host bits `0`, identifies the subnet itself).
> 2. **Broadcast Address** (all host bits `1`, broadcasts to all hosts on the subnet).

---

### 2. Private IP Address Ranges (RFC 1918)
Private IP addresses are non-routable over the public internet and are used inside internal corporate and local networks:
- **Class A:** `10.0.0.0` to `10.255.255.255` (`10.0.0.0/8`)
- **Class B:** `172.16.0.0` to `172.31.255.255` (`172.16.0.0/12`)
- **Class C:** `192.168.0.0` to `192.168.255.255` (`192.168.0.0/16`)

---

### 3. Subnetting Practical Calculations (From Class)

#### Case 1: Analyzing `120.27.1.0/8`
- **Class:** Class A (First octet 120 is between 1 and 127).
- **Default Subnet Mask:** `255.0.0.0`
- **Network Bits:** 8 bits
- **Host Bits:** $32 - 8 = 24$ bits
- **Total Hosts:** $2^{24} = 16,777,216$
- **Usable Hosts:** $2^{24} - 2 = 16,777,214$
- **Network ID:** `120.0.0.0`
- **Broadcast ID:** `120.255.255.255`

#### Case 2: Analyzing `197.23.45.10/24`
- **Class:** Class C (First octet 197 is between 192 and 223).
- **Default Subnet Mask:** `255.255.255.0`
- **Network Bits:** 24 bits
- **Host Bits:** $32 - 24 = 8$ bits
- **Usable Hosts:** $2^8 - 2 = 254$
- **Network ID:** `197.23.45.0`
- **Broadcast ID:** `197.23.45.255`

---

## 📌 Part 2: Practical Commands & Real Execution Outputs

---

### 🌐 1. `ping` (ICMP Reachability & Latency Check)

```bash
ping -c 4 google.com
```

**Output:**
```text
PING google.com (142.250.193.142) 56(84) bytes of data.
64 bytes from del11s05-in-f14.1e100.net (142.250.193.142): icmp_seq=1 ttl=116 time=14.2 ms
64 bytes from del11s05-in-f14.1e100.net (142.250.193.142): icmp_seq=2 ttl=116 time=13.8 ms
64 bytes from del11s05-in-f14.1e100.net (142.250.193.142): icmp_seq=3 ttl=116 time=15.1 ms
64 bytes from del11s05-in-f14.1e100.net (142.250.193.142): icmp_seq=4 ttl=116 time=14.0 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 13.812/14.275/15.102/0.498 ms
```
- **Student Insight:** `ping` uses ICMP Type 8 (Echo Request) and Type 0 (Echo Reply). 0% packet loss and low RTT confirms healthy Layer-3 bidirectional transport.

---

### 🌐 2. `traceroute` / `tracert` (Path & Hop Discovery)

```bash
traceroute -n -m 6 8.8.8.8
```

**Output:**
```text
traceroute to 8.8.8.8 (8.8.8.8), 6 hops max, 60 byte packets
 1  192.168.1.1  1.821 ms  1.745 ms  1.698 ms
 2  10.120.0.1  8.412 ms  8.389 ms  8.354 ms
 3  182.79.142.21  11.204 ms  11.190 ms  11.150 ms
 4  72.14.215.82  13.450 ms  13.412 ms  13.388 ms
 5  108.170.248.81  14.120 ms  14.090 ms  14.050 ms
 6  8.8.8.8  13.910 ms  13.880 ms  13.850 ms
```
- **Student Insight:** By systematically incrementing the IP TTL field from 1 upward, each router sends back an `ICMP Time Exceeded` packet, exposing intermediate gateway IPs.

---

### 🌐 3. `curl` (HTTP Client & Header Probing)

```bash
curl -I https://httpbin.org/get
```

**Output:**
```text
HTTP/2 200 
date: Wed, 02 Sep 2026 20:25:10 GMT
content-type: application/json
content-length: 304
server: gunicorn/19.9.0
access-control-allow-origin: *
```
- **Student Insight:** Passing `-I` sends an HTTP `HEAD` request, allowing engineers to verify server status, content headers, and SSL handshakes without fetching the body payload.

---

### 🌐 4. `nslookup` & `dig` (DNS Resolution)

```bash
nslookup github.com
```

**Output:**
```text
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	github.com
Address: 20.207.73.82
```
- **Student Insight:** Queries configured nameservers to resolve hostname to IP addresses. `dig github.com +short` gives direct, machine-parseable A-records.

---

### 🌐 5. `ss` / `netstat` (Socket Statistics & Open Ports)

```bash
sudo ss -tulnp
```

**Output:**
```text
Netid  State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process                                          
tcp    LISTEN  0       4096           0.0.0.0:80          0.0.0.0:*      users:(("nginx",pid=1120,fd=6))                  
tcp    LISTEN  0       128            0.0.0.0:22          0.0.0.0:*      users:(("sshd",pid=742,fd=3))                    
tcp    LISTEN  0       4096         127.0.0.1:3306        0.0.0.0:*      users:(("mysqld",pid=910,fd=21))                 
```
- **Student Insight:** `ss` directly interfaces with kernel netlink sockets, identifying open TCP/UDP listening ports and active process IDs.

---

### 🌐 6. `ip a` (Network Interfaces & CIDR)

```bash
ip a
```

**Output:**
```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet 172.28.140.231/20 brd 172.28.143.255 scope global eth0
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```
- **Student Insight:** `eth0` is the virtualized NIC assigned `172.28.140.231/20` (Class B private network), while `docker0` serves as the default Docker container bridge gateway (`172.17.0.1/16`).
