# Assignment - Dockerfiles & Images

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Dockerfiles & Images (Session 07 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 07 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Run Multi-Stage Dockerfile.** Write a multi-stage Dockerfile that separates the build environment from the runtime environment, build the image, and run the resulting container. I used a Go builder stage (`golang:1.22-alpine`) to compile a static binary, then copied only that binary into a lean `alpine:3.19` runtime stage, built the image as `devops-multistage-app:v1.0`, and ran it on port 8080.

**Task 2: Documentation.** Document the Dockerfile's build stages and show the image size reduction achieved by the multi-stage approach, with real verification output. I broke down what each stage does, captured `docker ps` to confirm the container was up, `curl`'d the running app to confirm it served the expected page, and ran `docker images` to compare the final image against the `golang:1.22` builder image it was built from.

**Task 3: Docker Application Deployment.** Deploy applications across different stacks using Docker containerization. I containerized and ran three separate stacks: a Node.js/Express app on port 3000, a Python/Flask app on port 5000, and a Java (JDK/Alpine) app on port 8080, each verified with a `curl` against its port.

**Deliverables:** multi-stage Dockerfile, build and run commands, container status and `curl` verification output, image size comparison, three additional stack deployments with verification, screenshots, README.md.

## 2. Notes

The size difference between the two stages is the whole point of this lab: my final production image came out to 12.4MB, against the `golang:1.22` builder image at 302MB, so the runtime image ends up over 95% smaller than the toolchain used to build it. That's because none of the Go compiler, source files, or build cache ever make it into the final `alpine:3.19` stage, only the compiled static binary does.

## 3. My completion checklist

- [x] Task 1: multi-stage Dockerfile written (Go builder stage, Alpine runtime stage), image built as `devops-multistage-app:v1.0`, container run and confirmed up with `docker ps`
- [x] Task 2: build stages documented, app verified reachable on port 8080 via `curl`, image size comparison captured with `docker images` (12.4MB final image vs. 302MB builder image)
- [x] Task 3: three additional stacks deployed and verified, Node.js/Express on port 3000, Python/Flask on port 5000, Java on port 8080
- [x] Screenshots: multi-stage app running on port 8080, `docker ps` container and image optimization metrics
