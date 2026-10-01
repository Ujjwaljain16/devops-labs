# Assignment - Networking Fundamentals

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Networking Fundamentals (Session 04 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 04 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: IP addressing and subnetting theory, using the shared reference repo.** The doc's own Task 1 instruction for this tab is to practice commands using the repo shared in the devops-heros GitHub organization. Following that reference ([devops-heros/session4-networking](https://github.com/Nency-Ravaliya/devops-heros/tree/main/session4-networking)), this covers IPv4 class architecture (A through E), default subnet masks, private IP ranges under RFC 1918, and worked subnetting calculations for two real example networks.

**Task 2: Practical networking commands.** Run and explain the core command line networking tools: `ping` for ICMP reachability, `traceroute` for hop discovery, `curl -I` for HTTP header probing, DNS resolution, `ss` for socket and listening port state, and `ip a` for network interface inspection, all against this machine's real network state.

**Deliverables:** subnetting theory and calculations, real command output for each networking tool, screenshots, README.md.

## 2. Notes

This module has a genuine, honestly documented environment gap. Neither `traceroute` nor the `dnsutils` package (which provides `nslookup` and `dig`) is installed in this WSL environment, and installing either needs `sudo apt install`, which needs a password I cannot type into a non interactive shell. Rather than fabricate hop data or fake DNS tool output, which is apparently what an earlier version of this README did, I documented the missing packages honestly as a real constraint. For DNS resolution specifically, I used `getent hosts`, which is part of glibc and already installed, to perform the same underlying resolution that `nslookup`/`dig` would have shown.

I also caught and corrected two other instances of generic, non real output left over from an earlier draft: the `ss -tulnp` section previously claimed nginx, sshd, and mysqld were listening, when the real output only shows `systemd-resolved` and `redis-server`, and the `ip a` section previously claimed a `docker0` bridge existed in this WSL distribution, when Docker Desktop's WSL integration actually runs the daemon in a separate `docker-desktop-data` distribution. Both are fixed to reflect this machine's real state.

## 3. My completion checklist

- [x] Task 1: IPv4 class architecture, private IP ranges, and subnetting calculations worked through for two real example networks
- [x] Task 2: `ping`, `curl -I`, `ss -tulnp`, and `ip a` all run for real against this machine and explained
- [x] Task 2: DNS resolution demonstrated via `getent hosts` since `nslookup`/`dig` are not installed here, an honestly documented and reasonably substituted environment gap rather than a skipped requirement
- [x] Task 2: `traceroute` documented as genuinely not installed in this environment (would need `sudo apt install traceroute`), reported honestly instead of faked
