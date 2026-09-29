# Assignment Breakdown: Docker Networking, Volumes & Docker Compose

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Docker Networking, Volumes & Docker Compose
**Date:** 1 September 2026
**Source:** Instructor's session transcript. The transcript's own source note claims it was "derived from the provided 'Kubernetes Fundamentals' transcript dated 1 September 2026," even though every section is Docker content. This is almost certainly the same upload-mislabeling issue I have seen elsewhere in this course's transcripts, and I am not inventing an explanation for it.

The execution and proof for everything below live in [README.md](README.md).

---

## 1. What's required

**Task 1: Network isolation.** A 3-network isolation exercise (frontend/backend/db), with proof that ping fails across separate networks.

**Task 2: Host networking.** Demonstrate `--network host` mode. This was not in the transcript, but I did it anyway.

**Task 3: Bind mounts.** A bind mount with a live update, with no rebuild required.

**Task 4: Overlay networks.** Concept only; this was not run locally.

**Task 5: Multi-network backend.** Attach the backend to two networks and verify with `docker inspect`. This was explicit homework that was missing from an earlier pass, and I added it in this pass.

**Task 6: Docker-managed volumes.** Covered as a class demo; also missing before, added in this pass.

**Task 7: Docker Compose.** Frontend, backend, and db as one stack; covered as a class demo, also added in this pass.

**Deliverables:** the networking and volumes demos, screenshots, README.md.

## 2. Notes

Tasks 1 through 4 were completed in an earlier pass on this same module. Tasks 5 through 7 are what this pass adds: the `docker network connect` plus `docker inspect` step, the named-volume demo, and the full Compose stack, none of which existed here before.

Task 5 needed the actual `docker inspect` evidence. Task 1's architecture diagram always assumed `lab-backend` would reach both networks, and the `docker network connect` command was even in the original command list, but there was never an actual `docker inspect` output proving the multi-network membership, which is the specific piece of evidence the transcript asks for (Section 4 of the source doc). Task 6 needed the Docker-managed volume demo, since Task 3 only ever demonstrated a bind mount, and the transcript's Section 9 explicitly contrasts that against Docker-managed volumes as a separate concept: data living in Docker's own storage rather than a host directory. Task 7 needed the Compose stack, since none of this module was Compose-based before; the transcript's Sections 10 and 11 describe a 3-service Compose stack (frontend/backend/db, with `build:` and `depends_on`) as core material, and it did not exist here at all.

I did not run a local overlay-network demo, since the transcript itself says this needs multiple Docker hosts to mean anything, and explains why the class did not run it locally either (Task 4 covers the concept and VXLAN mechanics instead). The transcript also does not state an exact deadline, submission portal, marks or weightage, or required screenshot count.

## 3. My completion checklist

- [x] Confirmed isolation first: `lab-frontend` to `lab-backend` succeeds, `lab-backend` to `lab-db` fails before connecting
- [x] Ran `docker network connect lab-db-net lab-backend`, then `docker inspect lab-backend` to show both `lab-frontend-net` and `lab-db-net` with distinct IPs
- [x] Re-tested `lab-backend` to `lab-db` after connecting, and it now succeeds
- [x] Ran `docker volume create my-data`, wrote data via one container, removed it, and read the same data back via a completely different container on the same volume
- [x] Built `compose-demo/`: a `docker-compose.yml` with `frontend` (Nginx and a bind mount), `backend` (built from a local Dockerfile), and `db` (MySQL and a named volume)
- [x] Ran `docker compose up -d --build`; the backend image was actually built from source, not pulled
- [x] Verified the frontend via `curl localhost:8085`
- [x] Verified frontend-to-backend connectivity via Compose's own service-name DNS (`backend:5000`), not `localhost`
- [x] Verified the `db` service and confirmed `MYSQL_DATABASE` auto-created the `compose_demo` database
- [x] Ran `docker compose down`, and confirmed the named volume survives by default (would need `-v` to actually delete it)
