# Networking Fundamentals - Commands & Output Analysis

**Name:** Ujjwal Jain  
**Topic:** Core Networking Commands, Socket Inspection, DNS Resolution & Route Tracing  

---

## 📌 Overview
Networking is the backbone of cloud infrastructure, distributed systems, and container orchestration. This document covers practical execution, realistic output logs, and humanized explanations of the most essential Linux/DevOps networking utilities.

---

## 🌐 Command 1: `ping` (Packet Internet Groper)

### What I Understood:
`ping` uses the **ICMP (Internet Control Message Protocol)** Echo Request (Type 8) and Echo Reply (Type 0) packets to test reachability between two hosts over an IP network. It measures Round-Trip Time (RTT) and calculates packet loss percentage.

### Command Execution:
```bash
ping -c 4 google.com
```

### Terminal Output:
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

> **Key takeaway:** 0% packet loss and an average latency of ~14.2 ms indicates healthy Layer-3 network connectivity.

---

## 🌐 Command 2: `traceroute` / `tracert` (Route Path Inspection)

### What I Understood:
`traceroute` discovers the layer-3 path (routers/hops) packets take to reach a destination. It works by sending packets with incrementing **TTL (Time to Live)** values starting from 1. Each intermediate router decrements TTL by 1 and sends back an `ICMP Time Exceeded` packet when TTL hits 0, revealing its IP.

### Command Execution:
```bash
traceroute -n -m 8 8.8.8.8
```

### Terminal Output:
```text
traceroute to 8.8.8.8 (8.8.8.8), 8 hops max, 60 byte packets
 1  192.168.1.1  1.821 ms  1.745 ms  1.698 ms
 2  10.120.0.1  8.412 ms  8.389 ms  8.354 ms
 3  182.79.142.21  11.204 ms  11.190 ms  11.150 ms
 4  72.14.215.82  13.450 ms  13.412 ms  13.388 ms
 5  108.170.248.81  14.120 ms  14.090 ms  14.050 ms
 6  142.250.238.99  14.512 ms  14.480 ms  14.440 ms
 7  8.8.8.8  13.910 ms  13.880 ms  13.850 ms
```

> **Key takeaway:** Identifies where bottlenecks, high latency, or packet drops occur along the network route.

---

## 🌐 Command 3: `curl` (Client URL)

### What I Understood:
`curl` is a command-line tool for transferring data using protocols such as HTTP, HTTPS, FTP, etc. In DevOps, it is used extensively to probe REST APIs, test microservice health endpoints, and inspect HTTP response headers.

### Command Execution:
```bash
# Fetch HTTP response headers only (-I / --head)
curl -I https://httpbin.org/get
```

### Terminal Output:
```text
HTTP/2 200 
date: Wed, 02 Sep 2026 13:46:12 GMT
content-type: application/json
content-length: 304
server: gunicorn/19.9.0
access-control-allow-origin: *
access-control-allow-credentials: true
```

> **Key takeaway:** Fast method to verify HTTP status codes (200, 301, 404, 502) and web server metadata without downloading the full body payload.

---

## 🌐 Command 4: `nslookup` and `dig` (DNS Queries)

### What I Understood:
`nslookup` and `dig` (Domain Information Groper) query Domain Name System (DNS) servers to map human-readable domain names to machine IP addresses (A/AAAA records) and check CNAME, MX, or TXT records.

### Command Execution:
```bash
nslookup github.com
```

### Terminal Output:
```text
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	github.com
Address: 20.207.73.82
```

### Advanced query using `dig`:
```bash
dig github.com +short
# Output: 20.207.73.82
```

> **Key takeaway:** Helps debug domain resolution failures and verifies that DNS caching and upstream resolvers are responding correctly.

---

## 🌐 Command 5: `ss` and `netstat` (Socket Statistics)

### What I Understood:
`ss` (Socket Statistics) is the modern replacement for `netstat`. It dumps socket information directly from the Linux kernel memory. It is crucial for determining which ports are open and which PID/service is binding to an interface.

### Command Execution:
```bash
# -t (TCP), -u (UDP), -l (Listening), -n (Numeric ports), -p (Process name)
sudo ss -tulnp
```

### Terminal Output:
```text
Netid  State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process                                          
tcp    LISTEN  0       4096           0.0.0.0:80          0.0.0.0:*      users:(("nginx",pid=1120,fd=6))                  
tcp    LISTEN  0       128            0.0.0.0:22          0.0.0.0:*      users:(("sshd",pid=742,fd=3))                    
tcp    LISTEN  0       4096         127.0.0.1:3306        0.0.0.0:*      users:(("mysqld",pid=910,fd=21))                 
tcp    LISTEN  0       128               [::]:22             [::]:*      users:(("sshd",pid=742,fd=4))                    
```

> **Key takeaway:** Quickly shows that Nginx is listening on port `80`, SSH on port `22`, and MySQL locally on `3306`.

---

## 🌐 Command 6: `ip a` (Interface & Address Configuration)

### What I Understood:
The `ip` tool replaces the legacy `ifconfig`. `ip a` (short for `ip addr show`) displays all active and inactive network interfaces, their assigned IPv4/IPv6 addresses, subnet masks (CIDR), MAC addresses (link/ether), and MTU size.

### Command Execution:
```bash
ip a
```

### Terminal Output:
```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:fc:19:92 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.55/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 84210sec preferred_lft 84210sec
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:e2:3a:41:c1 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
```

> **Key takeaway:** `lo` is the loopback interface (`127.0.0.1`), `eth0` is the physical/bridged Ethernet interface (`192.168.1.55/24`), and `docker0` is the virtual bridge gateway for container subnets (`172.17.0.1/16`).
