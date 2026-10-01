# Assignment - Docker Fundamentals

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Docker Fundamentals (Session 06 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 06 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

The task was to containerize Hello World applications across multiple tech stacks and runtimes, then demonstrate that each one actually builds, runs, and serves traffic from inside Docker. I covered 6 different stacks: Node.js (Express), Python (Flask), Java (built in HTTP server), Apache HTTP Server, React (single page app), and Nginx. For each one I wrote a Dockerfile, built an image, ran it as a named container on its own host port, and confirmed the response with both `curl` and a browser screenshot.

**Deliverables:** a Dockerfile and application source for each of the 6 stacks, a build/run/verify matrix documenting the exact commands used, `docker ps` output showing all 6 containers running at once, `curl` output confirming each endpoint's response body, screenshots of each app in the browser plus one of the full container matrix, and this README.md.

## 2. Notes

I gave each app its own host port (3000, 5000, 8080, 8081, 8082, 8083) instead of reusing port 80 or 8080 across containers, since several of these stacks (Apache, React, Nginx) all listen on port 80 inside their own container by default. Mapping them to distinct host ports let me run all 6 containers at the same time without any port conflicts, which is what the `docker ps` matrix in the README actually shows.

The Java app doesn't use a framework, it's a plain built in HTTP server, which made it the simplest Dockerfile of the 6 but also meant I had to handle the request/response plumbing manually instead of relying on something like Express or Flask doing it for me.

## 3. My completion checklist

- [x] Node.js (Express) app: built, run on port 3000, verified via `curl` and screenshot
- [x] Python (Flask) app: built, run on port 5000, verified via `curl` and screenshot
- [x] Java (built in HTTP server) app: built, run on port 8080, verified via `curl` and screenshot
- [x] Apache HTTP Server app: built, run on port 8081, verified via `curl` and screenshot
- [x] React single page app: built, run on port 8082, verified via `curl` and screenshot
- [x] Nginx web server app: built, run on port 8083, verified via `curl` and screenshot
- [x] All 6 containers confirmed running simultaneously via `docker ps`
- [x] Screenshots captured for all 6 apps plus the container status matrix
