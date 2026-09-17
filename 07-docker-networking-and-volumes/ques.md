# Assignment Breakdown — Docker Networking, Volumes & Docker Compose

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Docker Networking, Volumes & Docker Compose
**Date:** 1 September 2026
**Source:** Instructor's session transcript. Same caveat as the other transcript-derived docs in this repo: the doc's own source note claims it was "derived from the provided 'Kubernetes Fundamentals' transcript dated 1 September 2026" even though every section is Docker content — almost certainly the same upload-mislabeling issue seen elsewhere in this course's transcripts, not something I'm inventing an explanation for.

The execution/proof for everything below lives in [README.md](README.md).

---

## 1. What's actually assigned

| Work item | Status | Where it's done |
|---|---|---|
| 3-network isolation exercise (frontend/backend/db) | Explicit homework | Task 1 |
| Isolation proof (ping fails across separate networks) | Explicit homework | Task 1 |
| Host networking (`--network host`) | Extra, not in the transcript, done anyway | Task 2 |
| Bind mount + live update, no rebuild | Explicit homework | Task 3 |
| Overlay network — concept only, not run locally | Homework knowledge point | Task 4 |
| **Backend attached to two networks + `docker inspect` verification** | Explicit homework — **was missing**, added now | **Task 5** |
| **Docker-managed named volumes (vs. bind mount)** | Covered as class demo, **was missing**, added now | **Task 6** |
| **Docker Compose (frontend + backend + db as one stack)** | Covered as class demo, **was missing**, added now | **Task 7** |

Tasks 1–4 were completed in an earlier pass on this same module. Tasks 5–7 are what this pass adds — the doc's `docker network connect` + `docker inspect` step, the named-volume demo, and the full Compose stack, none of which existed here before.

## 2. Why Tasks 5–7 needed to be added, specifically

- **Task 5:** Task 1's architecture diagram always *assumed* `lab-backend` would reach both networks, and the `docker network connect` command was even in the original command list — but there was never an actual `docker inspect` output proving the multi-network membership, which is the specific piece of evidence the transcript asks for (§4 of the source doc).
- **Task 6:** Task 3 only ever demonstrated a bind mount. The transcript's §9 explicitly contrasts that against Docker-managed volumes (`-v volume-name:/path`) as a separate concept — data living in Docker's own storage rather than a host directory. Nothing in this module covered that distinction before.
- **Task 7:** None of this module was Compose-based before — everything was individual `docker network`/`docker run` commands. The transcript's §10–11 describe a 3-service Compose stack (frontend/backend/db, with `build:` and `depends_on`) as core material, which didn't exist here at all.

## 3. Deliberately not here

- A local overlay-network demo — the transcript itself says this needs multiple Docker hosts to mean anything, and explains why the class didn't run it locally either (Task 4 covers the concept and VXLAN mechanics instead)
- An exact deadline, submission portal, marks/weightage, or required screenshot count — none of these are stated in the transcript

## 4. Completion checklist (Tasks 5–7, the new work)

- [x] Confirmed isolation first: `lab-frontend → lab-backend` succeeds, `lab-backend → lab-db` fails before connecting
- [x] `docker network connect lab-db-net lab-backend`, then `docker inspect lab-backend` shows both `lab-frontend-net` and `lab-db-net` with distinct IPs
- [x] Re-tested `lab-backend → lab-db` after connecting — now succeeds
- [x] `docker volume create my-data`, wrote data via one container, removed it, read the same data back via a completely different container on the same volume
- [x] Built `compose-demo/` — `docker-compose.yml` with `frontend` (Nginx + bind mount), `backend` (built from a local Dockerfile), `db` (MySQL + named volume)
- [x] `docker compose up -d --build` — backend image actually built from source, not pulled
- [x] Verified frontend via `curl localhost:8085`
- [x] Verified frontend → backend connectivity via Compose's own service-name DNS (`backend:5000`), not `localhost`
- [x] Verified the `db` service and confirmed `MYSQL_DATABASE` auto-created the `compose_demo` database
- [x] `docker compose down`, confirmed the named volume survives by default (would need `-v` to actually delete it)
