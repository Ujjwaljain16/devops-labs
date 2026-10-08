# Session 21: TaskBoard - Run, Containerise, Compose, Test

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B
**Session:** 21 - Final DevOps Project & Troubleshooting (the TaskBoard homework part)

## What this is, and what it is not

This is the Session 21 homework on the **instructor's TaskBoard reference application**: run the full stack by hand, look at the two Dockerfiles, bring everything up with Docker Compose, and test the API and the UI.

The application code in this folder (`backend/`, `frontend/`, `docker-compose.yml`) is the instructor's template, copied **unchanged** from [Nency-Ravaliya/devops-heros](https://github.com/Nency-Ravaliya/devops-heros) (`session21-python`, commit `8376590`, 5 Oct 2026) so that every command below can be re-run from this folder. I verified the copied files are byte-identical to the originals. I did not write this application and I am not presenting it as my project.

**My own final project is a different application, CampusSlot**, with its own repository and pipeline: see [README.md](../README.md) in the parent folder. What is mine in *this* folder is the work of running, measuring, breaking and fixing the template, which is what the rest of this document records. Two small files are mine and are explained where they are used: [`docker-compose.hostport.yml`](docker-compose.hostport.yml) and [`docker-compose.healthcheck.yml`](docker-compose.healthcheck.yml).

Everything below was actually run on 8 October 2026 (Windows 11, Docker Desktop 29.0.1, Python 3.13.1, Node 22.19.0). The outputs are copied from those runs, and where something did not work I say so.

---

## Architecture

```text
 Browser ──:3000──> frontend container (Nginx serves the React build)
                         │  /api/*  and  /health  are proxied to  backend:8000
                         ▼
                    backend container (FastAPI + Uvicorn, runs Alembic first)
                         │  postgresql+psycopg://...@postgres:5432/taskboard
                         ▼
                    postgres container (PostgreSQL 16, named volume postgres-data)
```

---

## Task 1: Running the application manually

Three pieces started by hand, no Compose.

### 1.1 PostgreSQL

My machine already runs a native PostgreSQL service on port 5432 (not mine to stop), so I published the container on **5433** instead:

```bash
docker run -d --name taskboard-db \
  -e POSTGRES_DB=taskboard -e POSTGRES_USER=taskboard -e POSTGRES_PASSWORD=taskboard \
  -p 5433:5432 postgres:16-alpine
docker exec taskboard-db pg_isready -U taskboard -d taskboard
```
```text
/var/run/postgresql:5432 - accepting connections
taskboard-db | postgres:16-alpine | Up 3 seconds | 0.0.0.0:5433->5432/tcp
```

### 1.2 Backend (FastAPI + Alembic)

The README asks for Python 3.12+. My `py -3.12` is a broken Microsoft Store stub (the file does not exist), so I used the installed **Python 3.13.1**:

```bash
cd backend
py -3.13 -m venv .venv
.venv/Scripts/python.exe -m pip install -r requirements.txt      # exit code 0
export DATABASE_URL="postgresql+psycopg://taskboard:taskboard@localhost:5433/taskboard"
.venv/Scripts/python.exe -m alembic upgrade head
```
```text
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> 0001_create_tasks
```
Checking what the migration actually created, in PostgreSQL itself:
```text
 Schema |      Name       | Type  |   Owner
--------+-----------------+-------+-----------
 public | alembic_version | table | taskboard
 public | tasks           | table | taskboard

    version_num
-------------------
 0001_create_tasks
```
Then the server:
```bash
.venv/Scripts/python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```
```text
$ curl http://localhost:8000/health
{"status":"UP"}
$ curl http://localhost:8000/
{"service":"TaskBoard API","version":"1.0.0","docs":"/docs"}
$ curl http://localhost:8000/ready
{"status":"READY"}
$ curl http://localhost:8000/api/tasks
[]
$ curl -I http://localhost:8000/docs
HTTP/1.1 200 OK
```
To prove the backend really talks to the database, I wrote a task through the API and read the same row straight out of PostgreSQL:
```text
$ curl -X POST http://localhost:8000/api/tasks -H "Content-Type: application/json" \
    -d '{"title":"Manual run check","priority":"HIGH","assignee":"Ujjwal"}'
{"title":"Manual run check","description":"","priority":"HIGH","status":"TODO","assignee":"Ujjwal","id":1,"created_at":"2026-10-08T12:35:20.077463Z"}

$ docker exec taskboard-db psql -U taskboard -d taskboard -c "SELECT id, title, priority, assignee FROM tasks;"
 id |      title       | priority | assignee
----+------------------+----------+----------
  1 | Manual run check | HIGH     | Ujjwal
```

### 1.3 Frontend (React + Vite)

```bash
cd frontend
npm install                                   # added 19 packages in 33s, exit code 0
npm run dev -- --host 0.0.0.0 --port 3000
```
`package.json` uses `"latest"` for every dependency, so what I got today was `vite@8.3.4`, `react@19.3.0`, `@vitejs/plugin-react@6.1.2`. The server came up (`VITE v8.3.4 ready in 1712 ms`) and served the page (`GET / -> 200 text/html`).

**A real mismatch in the template.** `vite.config.js` proxies `/api` to `http://localhost:8080`, but the README runs the backend on **8000**. With the template exactly as shipped:
```text
$ curl http://localhost:3000/api/tasks
http_code=502
[vite] http proxy error: /api/tasks
AggregateError [ECONNREFUSED]
```
The page loads but cannot reach any data. I did not edit the template. I started a **second** backend on port 8080 (same database) so the proxy had a target:
```text
$ curl http://localhost:3000/api/tasks          # browser-facing port -> Vite proxy -> backend:8080 -> PostgreSQL
[{"title":"Manual run check","description":"","priority":"HIGH","status":"TODO","assignee":"Ujjwal","id":1,"created_at":"2026-10-08T12:35:20.077463Z"}]
$ curl http://localhost:3000/api/tasks/stats
{"total":1,"todo":1,"inProgress":0,"done":0}
```
That is the whole manual chain working: frontend -> proxy -> backend -> PostgreSQL. (The mismatch does not exist in Compose, where Nginx proxies to `backend:8000`.)

### Part C of the instructor's README: pytest

```bash
cd backend && pytest -q
```
```text
FAILED tests/test_api.py::test_create_task_validation - sqlalchemy.exc.OperationalError
1 failed, 2 passed
```
This is a bug in the template, and I confirmed the cause instead of guessing:
```text
E   sqlite3.OperationalError: no such table: tasks
```
`app/main.py` does create the tables in a startup hook ("create_all keeps tests self-contained"), but the test builds `client = TestClient(app)` **outside a `with` block**, and Starlette only fires startup events inside one. So the empty `test.db` never gets a `tasks` table. To prove that is the whole cause, I created the table myself and re-ran the **same, unchanged** tests:
```text
tasks table created in test.db
...                                                                      [100%]
3 passed in 0.67s
```
So on a fresh checkout `pytest -q` fails 1 of 3. (This matters for the instructor's pipeline idea, "pytest fails, no image is promoted": as shipped, the first gate would stop on its own.)

I then stopped the manual stack and removed the database container (`docker rm -fv taskboard-db`) so the ports were free for Compose.

---

## Task 2: Containerisation with Dockerfiles

Both Dockerfiles come with the template; here I built them with the README's commands and checked what they actually produce.

**`backend/Dockerfile`**
```dockerfile
FROM python:3.12-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && useradd --create-home --uid 10001 appuser
COPY alembic.ini ./
COPY alembic ./alembic
COPY app ./app
USER 10001
EXPOSE 8000
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
```
**`frontend/Dockerfile`** (multi-stage)
```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```
```bash
docker build -t taskboard-backend:local ./backend                 # exit 0
docker build -t taskboard-frontend:local ./frontend               # exit 0
docker build --target build -t taskboard-frontend:buildstage ./frontend   # only to measure the build stage
docker images
```
```text
REPOSITORY:TAG                        SIZE
taskboard-frontend:local              48.5MB
taskboard-frontend:buildstage         269MB
taskboard-backend:local               205MB
```
Checking the claims the instructor's README makes about these images:
```text
$ docker run --rm --entrypoint id taskboard-backend:local
uid=10001(appuser) gid=10001(appuser) groups=10001(appuser)        <- runs as non-root

$ docker run --rm --entrypoint sh taskboard-frontend:local -c 'command -v node; command -v npm; ls /usr/share/nginx/html'
node: absent
npm: absent
50x.html  assets  index.html                                       <- no build tooling in the runtime image

$ docker run --rm --entrypoint sh taskboard-frontend:buildstage -c 'node --version; ls node_modules | wc -l'
node: v22.23.3
node_modules packages: 19                                          <- ...but the build stage has all of it
```
**Measured, not assumed:** the multi-stage build takes the frontend from **269 MB to 48.5 MB** (about 82 percent smaller). Of those 48.5 MB, the app's own `dist/` layer is only 234 kB; nearly all the rest is the Nginx base image.

---

## Task 3: Orchestration with Docker Compose

### 3.1 The compose file (the instructor's, unchanged)

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: taskboard
      POSTGRES_USER: taskboard
      POSTGRES_PASSWORD: taskboard
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql+psycopg://taskboard:taskboard@postgres:5432/taskboard
    depends_on:
      - postgres
    ports:
      - "8000:8000"

  frontend:
    build: ./frontend
    depends_on:
      - backend
    ports:
      - "3000:80"

volumes:
  postgres-data:
```
The backend reaches the database by the service name `postgres`, which Compose's built-in DNS resolves, so no IP is hard-coded.

### 3.2 My port override

Because my machine's native PostgreSQL holds host port 5432, I did not edit the instructor's file. [`docker-compose.hostport.yml`](docker-compose.hostport.yml) remaps only the host side:
```yaml
services:
  postgres:
    ports: !override
      - "5433:5432"
```
Containers still talk to each other on 5432 inside Docker, so only the published port changes. **If your port 5432 is free you do not need this file.**

### 3.3 `docker compose up -d --build`, and a cold-start failure

```bash
docker compose -f docker-compose.yml -f docker-compose.hostport.yml up -d --build
```
```text
 session21-python-backend  Built
 session21-python-frontend  Built
 Network session21-python_default  Created
 Volume session21-python_postgres-data  Created
 Container session21-python-postgres-1  Started
 Container session21-python-backend-1  Started
 Container session21-python-frontend-1  Started
```
`up` exited 0 and said "Started" for all three. But a minute later, `docker compose ps` listed **only two**, and `ps -a` showed why:
```text
SERVICE    STATUS
backend    Exited (1) About a minute ago
frontend   Up About a minute
postgres   Up About a minute
```
The backend had crashed. `docker compose ps` hides exited containers, so this is easy to miss. The log has the actual reason:
```text
sqlalchemy.exc.OperationalError: (psycopg.OperationalError) connection failed:
connection to server at "172.19.0.2", port 5432 failed: Connection refused
```
and Postgres's own log gives the timeline:
```text
postgres-1  | PostgreSQL init process complete; ready for start up.
postgres-1  | 2026-10-08 12:39:41.484 UTC [1] LOG:  database system is ready to accept connections
```
**Root cause:** `depends_on` only orders the *start* of containers, it does not wait for Postgres to be *ready*. On a fresh volume, Postgres first runs `initdb` and a temporary server, and refuses connections until it is done. The backend runs `alembic upgrade head` the instant it starts, fails once, exits, and nothing restarts it (no `restart:` policy, no healthcheck).

I confirmed it only happens on a **cold** start. After a plain `docker compose down` (volume kept) and `up -d`, Postgres already has its data directory, comes up fast, and the backend started fine in about 3 seconds.

Recovering by hand worked (running `docker compose up -d` again starts the exited backend, now that Postgres is ready):
```text
$ docker compose ... up -d
 Container session21-python-backend-1  Starting
 Container session21-python-backend-1  Started
backend-1  | INFO  [alembic.runtime.migration] Running upgrade  -> 0001_create_tasks
backend-1  | INFO:     Application startup complete.
```

### 3.4 The fix: a healthcheck override

[`docker-compose.healthcheck.yml`](docker-compose.healthcheck.yml) makes the backend wait until Postgres reports **healthy**:
```yaml
services:
  postgres:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskboard -d taskboard"]
      interval: 2s
      timeout: 3s
      retries: 20
  backend:
    depends_on: !override
      postgres:
        condition: service_healthy
```
To test it properly I needed a cold start again, so I deleted the volume with `docker compose down -v` (this one *does* remove the data, which is the difference from plain `down`) and started from scratch:
```text
$ docker compose -f docker-compose.yml -f docker-compose.hostport.yml -f docker-compose.healthcheck.yml up -d
 Container session21-python-postgres-1  Started
 Container session21-python-postgres-1  Waiting
 Container session21-python-postgres-1  Healthy          <- backend does not start until this line
 Container session21-python-backend-1  Starting
 Container session21-python-backend-1  Started
 Container session21-python-frontend-1  Started

SERVICE    STATUS
backend    Up 12 seconds
frontend   Up 12 seconds
postgres   Up 14 seconds (healthy)

tracebacks / "connection refused" in the backend log: 0
restarts: backend=0 postgres=0 frontend=0
```
Same cold start that killed the backend before, now all three come up first time. (I verified a write through the frontend on the brand-new database too: `POST /api/tasks` returned `"id":1`.)

### 3.5 Data persistence

```text
$ docker compose down            # no -v
$ docker volume ls | grep postgres-data
session21-python_postgres-data   <- still there
$ docker compose up -d
$ SELECT id, title, status FROM tasks ORDER BY id;
 id |            title            |   status
----+-----------------------------+-------------
  1 | Set up Docker Compose       | DONE
  2 | Write the README            | IN_PROGRESS
  4 | Created from the browser UI | IN_PROGRESS
```
All three rows survived a full `down` and `up`. `docker compose down -v` is the one that deletes the volume (shown in 3.4).

---

## Task 4: Application and API testing

### 4.1 Health, docs and metrics

```text
$ curl http://localhost:8000/health
{"status":"UP"}
$ curl http://localhost:8000/ready          (this one touches the database)
{"status":"READY"}
$ curl -I http://localhost:8000/docs
HTTP/1.1 200 OK

routes (from /openapi.json):
  GET /metrics   GET /   GET /health   GET /ready
  GET /api/tasks   POST /api/tasks   GET /api/tasks/stats
  GET /api/tasks/{task_id}   PUT /api/tasks/{task_id}   DELETE /api/tasks/{task_id}

$ curl http://localhost:8000/metrics | grep http_requests_total
http_requests_total{handler="/health",method="GET",status="2xx"} 2.0
http_requests_total{handler="/ready",method="GET",status="2xx"} 1.0
```
(The `/metrics` counters show my own requests being recorded, so the Prometheus endpoint is live.)

### 4.2 Task CRUD

Valid values come from `schemas.py`: status `TODO | IN_PROGRESS | DONE`, priority `LOW | MEDIUM | HIGH`.
```text
CREATE x3
{"title":"Set up Docker Compose","description":"Deploy the TaskBoard stack","priority":"HIGH","status":"TODO","assignee":"Ujjwal","id":1,...}
{"title":"Write the README","description":"","priority":"MEDIUM","status":"IN_PROGRESS","assignee":"Ujjwal","id":2,...}
{"title":"Take screenshots","description":"","priority":"LOW","status":"TODO","assignee":"Unassigned","id":3,...}

READ list (newest first) -> ids 3, 2, 1          READ one: GET /api/tasks/1 -> task 1
UPDATE: PUT /api/tasks/1 {"status":"DONE"}  -> "status":"DONE"
STATS: {"total":3,"todo":1,"inProgress":1,"done":1}

DELETE /api/tasks/3 -> http 204
GET    /api/tasks/3 -> http 404   {"detail":"Task not found"}

error handling:
POST invalid priority ("URGENT") -> http 422
POST empty title                 -> http 422
PUT  nonexistent id (999)        -> http 404
```
Read independently from PostgreSQL (not through the API):
```text
 id |         title         | priority |   status    | assignee
----+-----------------------+----------+-------------+----------
  1 | Set up Docker Compose | HIGH     | DONE        | Ujjwal
  2 | Write the README      | MEDIUM   | IN_PROGRESS | Ujjwal
```

### 4.3 The frontend in a real browser

At the container level first: `GET /` -> `200 text/html` (`<title>TaskBoard</title>`), both built assets are served (`/assets/index-*.js` 227,223 bytes and `/assets/index-*.css` 6,401 bytes, both 200), an unknown deep link still returns `index.html` (so the single-page app routing works), and the Nginx proxy reaches the backend:
```text
$ curl http://localhost:3000/api/tasks/stats
{"total":2,"todo":0,"inProgress":1,"done":1}
$ curl http://localhost:3000/health
{"status":"UP"}
```
Then I opened `http://localhost:3000` and read what React actually rendered: the KPI cards (Total 2 / To do 0 / In progress 1 / Completed 1) matched the stats endpoint, the table listed my tasks with the right priorities and statuses, and the browser console had no errors.

**Creating a task from the UI** (the "New task" button, title/description/assignee, "Create task"): the backend log shows `POST /api/tasks 201 Created` coming from the frontend container, and PostgreSQL has the new row (`id 4`, "Created from the browser UI"; id 3 was the task I had deleted, and a sequence does not reuse ids). **But the page did not refresh**: the modal stayed open and the list still said Total 2 until I reloaded. The browser console says why:
```text
Uncaught (in promise) TypeError: Cannot read properties of null (reading 'reset')
```
That is a bug in the template's handler:
```js
const create = async (e) => {
  e.preventDefault();
  const f = new FormData(e.currentTarget);
  await fetch(`${API}/tasks`, { method: 'POST', ... });
  e.currentTarget.reset();      // <- after an await, e.currentTarget is null: this throws
  setShowForm(false); load()    // <- so these two never run
};
```
The write succeeds, but `e.currentTarget` is `null` once the event dispatch has finished, so the line after the `await` throws and the modal-close and reload never run. (The fix would be to grab the form element before the `await`.) After a reload the task was there (Total 3, To do 1).

**Advancing a status** (the "Advance status" button): the backend log shows `PUT /api/tasks/4 200 OK` from the frontend container, and the task went `TODO -> IN_PROGRESS` in both the API and PostgreSQL. (My first click did not register because the browser pane was not drawn, and I checked the log and DB rather than assume. The retry worked.)

Not live: the greeting ("Good morning, Nensi") and the "Recent activity" feed are written into the JSX; the only calls the page makes are `/tasks`, `/tasks/stats` and the create/update requests.

---

## Screenshots

These were taken in my own terminal and browser, running the commands from this folder. One thing looks different from the text transcripts above: the containers are named **`taskboard-compose-*`** here, but **`session21-python-*`** in the transcripts. Docker Compose names a project after the directory it runs in, and I ran the earlier tests from a scratch copy of the template; from this folder the name is `taskboard-compose`. Nothing else differs.

**1. `docker compose up -d --build`** (started from nothing, after `down -v`): the build finishes in 18.2s with `npm install` (13.5s) and `pip install` (12.9s) doing real work, then the network and the volume are created, **`postgres` goes `Healthy` first**, and only then do `backend` and `frontend` start. That ordering is the healthcheck override from section 3.4 working.

![docker compose up -d --build](screenshots/01_compose_up_build.png)

**2. `docker compose ps`**: all three services up, Postgres `(healthy)`, published on 8000, 3000 and 5433 (5433 because my machine's own PostgreSQL holds 5432).

![docker compose ps](screenshots/02_compose_ps.png)

**3. Swagger UI at `http://localhost:8000/docs`**: the ten routes the API exposes (`/metrics`, `/`, `/health`, `/ready`, and the five task routes plus `/api/tasks/stats`).

![Swagger UI](screenshots/03_swagger_docs.png)

**4. The API tests in the terminal**: health and ready, two creates (ids 1 and 2), the status update of task 1 to `DONE`, the list, the stats (`total 2, todo 0, inProgress 1, done 1`), and the two error cases (`422` for an invalid priority, `404` for an unknown id).

![API CRUD tests](screenshots/04_api_crud_tests.png)

**5. The frontend at `http://localhost:3000`**: the dashboard shows the same data the API tests just created, with the stat cards (Total 2, To do 0, In progress 1, Completed 1) matching `/api/tasks/stats` and both tasks in the table. The greeting ("Good morning, Nensi"), the sidebar profile and the "Recent activity" feed are static placeholder text in the instructor's template, as noted in section 4.3; only the cards and the table are live.

![TaskBoard frontend](screenshots/05_frontend_ui.png)

I did not capture screenshots of two of the findings below: the cold-start crash (finding 1) and the UI console error (finding 5). Their evidence is the log and console text quoted in sections 3.3 and 4.3, taken from the real runs.

---

## Findings at a glance

| # | Finding | Evidence |
|---|---|---|
| 1 | `docker compose up` on a fresh volume leaves the backend dead (`depends_on` does not wait for readiness); `ps` hides it | Section 3.3, exit code 1 and "Connection refused" |
| 2 | A Postgres healthcheck + `condition: service_healthy` fixes it, and a warm start never had the problem | Sections 3.4 and 3.3 |
| 3 | Vite's dev proxy targets `:8080` while the backend runs on `:8000` | Section 1.3, 502 / ECONNREFUSED |
| 4 | `pytest -q` fails 1 of 3 on a fresh checkout (`no such table: tasks`); the same tests pass once the table exists | Section "Part C" |
| 5 | Creating a task in the UI succeeds but the page does not refresh (`e.currentTarget` is null after `await`) | Section 4.3, console error + 201 in the log |
| 6 | Multi-stage build measured: frontend 269 MB -> 48.5 MB; backend runs as uid 10001; no Node in the runtime image | Section 2 |

## Re-running this

```bash
cd 20-final-devops-project/taskboard-compose
# if host port 5432 is free, drop the first override file
docker compose -f docker-compose.yml -f docker-compose.hostport.yml -f docker-compose.healthcheck.yml up -d --build
docker compose -f docker-compose.yml -f docker-compose.hostport.yml -f docker-compose.healthcheck.yml ps
curl http://localhost:8000/health        # then open http://localhost:3000 and http://localhost:8000/docs
docker compose -f docker-compose.yml -f docker-compose.hostport.yml -f docker-compose.healthcheck.yml down -v
```
