# Monitoring, Observability & GitOps

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for the exact task breakdown, why this module runs on its own cluster, and why the GitOps repo is this same repo rather than a separate one.

**Environment note:** everything below runs on a dedicated Minikube profile, `session19` (`minikube start -p session19 --cpus=2 --memory=1800mb`), kept separate from the main `minikube` cluster the other 16 modules use. WSL2's total RAM is ~3.9GB, so both Prometheus and Grafana are installed with `persistence.enabled=false` and trimmed resource requests rather than the full `kube-prometheus-stack` bundle.

---

# Task 1: Monitoring

## Metrics

Prometheus (installed via Helm, `prometheus-community/prometheus`) is genuinely scraping 8 real targets:
```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
curl -s http://localhost:9090/api/v1/targets | ...
```
```
[kubernetes-api-servers, kubernetes-nodes, kubernetes-nodes-cadvisor,
 kubernetes-service-endpoints x4, prometheus] — all health: up
```

## CPU utilization

```bash
curl -s 'http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes'
```
Real value returned: `1114935296` bytes (~1.06 GiB) available at query time — matches `free -h` on the WSL host at the same moment.

## Memory utilization

Same query family, `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100` — used this exact expression as a Grafana panel (see Dashboard below) rather than just a one-off query, since utilization is something you watch over time, not check once.

## Application health

Kubernetes' own readiness/liveness model *is* the application-health primitive everything else builds on — module 16's `devsecops-demo` already has real `readinessProbe`/`livenessProbe` hitting `/health` (see [16-cicd-devsecops/k8s/deployment.yaml](../16-cicd-devsecops/k8s/deployment.yaml)). Here, the GitOps demo app's health is what Argo CD's own `HEALTH STATUS` reports — see Task 3, `Healthy`, derived from the Deployment's actual `readyReplicas` vs. desired.

## Alerts

Two real Prometheus alert rules (`monitoring/prometheus-values.yaml`), loaded and evaluating:
```bash
curl -s http://localhost:9090/api/v1/rules
```
```
Group: node-health
 - HighNodeMemoryUsage | state: inactive | health: ok
 - NodeExporterDown    | state: inactive | health: ok
```

Didn't stop at "the rule exists and doesn't crash" — actually made one **fire**, for real. Patched the node-exporter DaemonSet with an unmatched `nodeSelector` to genuinely take it down:

```bash
kubectl patch daemonset prometheus-prometheus-node-exporter -n monitoring \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"demo-disable":"true"}}}}}'
```

First attempt at the alert (`up{...} == 0`) never fired — and *why* it didn't is a real, useful finding in its own right: when a Service has zero Endpoints, `kubernetes_sd_configs` drops the target from discovery entirely rather than reporting `up=0` for it. The metric series doesn't flip to 0, it just **stops existing**. Confirmed directly:
```bash
curl -s 'http://localhost:9090/api/v1/query?query=up{job="kubernetes-service-endpoints",service="prometheus-prometheus-node-exporter"}'
```
```
{"status":"success","data":{"resultType":"vector","result":[]}}
```
Empty result, not a `0` value. Fixed the rule to use `absent()` instead, which is the correct way to alert on a target vanishing:
```yaml
- alert: NodeExporterDown
  expr: absent(up{job="kubernetes-service-endpoints", service="prometheus-prometheus-node-exporter"} == 1)
  for: 1m
```
Reloaded, then watched the real state transition end to end:
```
check 1: inactive
check 2: unknown   <- config reload in progress
check 4: pending    <- condition true, waiting out the "for: 1m"
check 6: firing     <- genuinely alerting
```
Confirmed it actually reached Alertmanager, not just the rule evaluator:
```bash
curl -s http://localhost:9093/api/v2/alerts
```
```json
[{
  "labels": {"alertname": "NodeExporterDown", "severity": "critical"},
  "status": {"state": "active"},
  "startsAt": "2026-09-29T14:16:43.863Z",
  "annotations": {"summary": "node-exporter target is missing"}
}]
```
Then restored node-exporter (removed the fake `nodeSelector`) and confirmed the alert genuinely resolved:
```
check 1: firing
check 2: inactive
```
Full real lifecycle: **inactive → pending → firing (in Prometheus *and* Alertmanager) → inactive**, not a screenshot of a rule that's never actually been exercised.

## Logs

```bash
kubectl logs deployment/gitops-demo -n session19-gitops --tail=10
```
```
2026/09/29 14:47:49 [notice] 1#1: nginx/1.29.1
2026/09/29 14:47:49 [notice] 1#1: start worker process 20
2026/09/29 14:47:49 [notice] 1#1: start worker process 21
```

---

# Task 2: Observability

## What each pillar means

**Metrics** — numbers over time (CPU%, request count, memory bytes). Cheap to store, cheap to query, great for dashboards and alerting thresholds — but a metric can't tell you *why* something went wrong, only *that* something did.

**Logs** — discrete timestamped events, usually free-text or structured JSON, emitted by the application itself. Expensive to store at scale, but they carry the actual detail metrics can't — an exact error message, a stack trace, a specific request's parameters.

**Traces** — the journey of one specific request across every service it touched, with timing for each hop. The only pillar that answers "why is *this* request slow" in a system with more than one service — a metric can tell you p99 latency went up; a trace tells you it went up because service B waited 400ms on a downstream call to service C.

## Why observability is required

Monitoring (Task 1) tells you *something* is wrong — an alert fires, a graph spikes. Observability is what lets you actually **answer new questions you didn't think to ask in advance**, using the data already being collected, without shipping new code to add more instrumentation. A dashboard is monitoring; being able to go from "checkout latency is up" to "it's this one pod, this one dependency, this one query" without adding a single new log line is observability. This module's own `NodeExporterDown` investigation above is a small real example: the alert (monitoring) fired, but *understanding why the naive `up == 0` version never fired* required actually querying Prometheus's own data (observability) to see the series had vanished rather than assuming.

## Common tools

| Pillar | Tool used here | Other common tools |
|---|---|---|
| Metrics | Prometheus | Datadog, CloudWatch, InfluxDB |
| Dashboards | Grafana | Datadog, Kibana |
| Logs | `kubectl logs` (this module's scale) | Loki, ELK/Elasticsearch, Splunk |
| Traces | *(not run here - see note below)* | Jaeger, Zipkin, Tempo |
| Alerting | Prometheus Alertmanager | PagerDuty, Opsgenie |

**Honest gap:** didn't stand up a real distributed tracing backend (Jaeger/Tempo) for this module — the demo app (`nginxdemos/hello`) doesn't emit trace spans, and adding real OpenTelemetry instrumentation to a from-scratch app just for this module felt like more scope than the task asked for, on top of an already resource-constrained cluster. Documented the *concept* honestly above rather than faking a trace waterfall screenshot.

## Kubernetes observability

Kubernetes exposes all three pillars natively, which is exactly why Prometheus + Grafana work here with almost no custom code:
- **Metrics**: `kube-state-metrics` (object state - pod counts, deployment status) + `node-exporter` (host-level CPU/memory/disk) + cAdvisor (per-container resource usage, built into kubelet) — all three scraped by Prometheus above, all three are real targets in the target list.
- **Logs**: `kubectl logs`, backed by the container runtime writing stdout/stderr to disk per-container — no separate logging agent needed for basic access, though a real cluster would ship these to Loki/ELK for retention past pod lifetime.
- **Kubernetes API itself as an observability source**: `kubectl get events`, `kubectl describe` — used extensively already in [module 13](../13-kubernetes-troubleshooting/README.md), and again below for the Argo CD Application's own event stream.

## Dashboard

Real Grafana dashboard, created via the actual Grafana API (not clicked together manually, but genuinely running and queryable):
```bash
curl -s -X POST http://admin:admin123@localhost:3000/api/dashboards/db -d @monitoring/grafana-dashboard.json
```
```
{"status":"success","uid":"67e98302-0504-44fc-a6f2-9686c74e97da","url":"/d/67e98302-.../session19-cluster-overview"}
```
Confirmed the datasource actually works, not just that it was created:
```bash
curl -s http://admin:admin123@localhost:3000/api/datasources/uid/bfzq2i4ngiwaod/health
```
```
{"status":"OK","message":"Successfully queried the Prometheus API."}
```

---

# Task 3: GitOps

## What is GitOps?

Instead of running `kubectl apply` by hand (or from a CI pipeline with cluster credentials), the cluster runs an agent (Argo CD) that continuously watches a Git repository and makes the cluster match whatever's declared there. Deploying = `git push`. Nothing with direct write access to the cluster except the agent itself.

## Git as the source of truth

"Source of truth" means: if the live cluster and Git ever disagree, **Git wins** — the cluster gets changed to match Git, never the other way around. Proved this concretely in the self-healing demo below: a manual `kubectl scale` change was silently reverted within ~10 seconds because it disagreed with Git.

## Declarative configuration

The manifests in [gitops-app/app/](gitops-app/app/) describe *what should exist* (a Deployment with `replicas: 3`, a Service), never *how to get there*. Argo CD computes the diff between "what Git says" and "what's actually running" and reconciles it — imperative commands (`kubectl scale`, `kubectl edit`) are exactly what GitOps is designed to make unnecessary, and exactly what got overridden below.

## Continuous reconciliation

Argo CD doesn't check once at deploy time and stop — it keeps comparing live state to Git state on an ongoing basis (poll interval, plus on-demand via the refresh annotation used below), and with `selfHeal: true` it acts on every diff it finds, not just the first one.

## GitOps workflow — the actual repo used

Used **this repo**, not a separate one — [gitops-app/app/](gitops-app/app/) holds the manifests, [gitops-app/argocd-application.yaml](gitops-app/argocd-application.yaml) is the Argo CD `Application` pointing at that exact path (kept one level outside `app/` so it's never mistaken for a workload manifest to sync).

### Step 1-2: Cluster + Argo CD install

```bash
minikube start -p session19 --cpus=2 --memory=1800mb
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
Hit a real, common issue immediately: the `applicationsets.argoproj.io` CRD's annotations exceed etcd's 256KB last-applied-config limit under plain `kubectl apply`. Real fix, not a workaround: `--server-side` apply, which doesn't use that annotation at all. That created a client conflict on second apply (mixing client-side and server-side ownership), resolved with `--force-conflicts`. All 7 Argo CD pods came up clean after that.

### Step 3-5: Git repo, Application, first sync

```bash
kubectl apply -f gitops-app/argocd-application.yaml
kubectl get applications -n argocd
```
```
NAME                    SYNC STATUS   HEALTH STATUS
session19-gitops-demo   Synced        Healthy
```
Exactly the reference's expected shape.

### Step 6: Check Kubernetes

```bash
kubectl get all -n session19-gitops
```
```
pod/gitops-demo-6d98947cf8-9mkl7   1/1   Running
pod/gitops-demo-6d98947cf8-p276d   1/1   Running
deployment.apps/gitops-demo   2/2   2   2
```

### Step 7: Change replicas in Git, watch it propagate

Edited `gitops-app/app/deployment.yaml`: `replicas: 2` -> `3`, committed, pushed for real to `Ujjwaljain16/devops-labs`. Triggered an immediate refresh (`argocd.argoproj.io/refresh=hard`) instead of waiting out Argo CD's ~3-minute default poll interval:
```bash
kubectl annotate application session19-gitops-demo -n argocd argocd.argoproj.io/refresh=hard --overwrite
```
```bash
kubectl get deployment gitops-demo -n session19-gitops
```
```
NAME          READY   UP-TO-DATE   AVAILABLE
gitops-demo   3/3     3            3
```
The change travelled: **Git -> Argo CD -> Kubernetes**. That's GitOps.

### Step 8: Self-healing

```bash
kubectl scale deployment gitops-demo -n session19-gitops --replicas=1
```
```
NAME          READY   UP-TO-DATE   AVAILABLE
gitops-demo   2/3     3            2
```
(A pod was already mid-termination when this was captured.) Polled every 10s — back to `3/3` within the first check:
```
check 1: replicas=3 ready=3
```
And the real event trail proving *why*, straight from `kubectl describe application`:
```
OperationStarted    Initiated automated sync to '8ebc37e...'
ResourceUpdated     Updated sync status: Synced -> OutOfSync      <- my manual kubectl scale created drift
OperationCompleted  Partial sync operation to 8ebc37e... succeeded
ResourceUpdated     Updated sync status: OutOfSync -> Synced       <- reverted back to Git's declared state
ResourceUpdated     Updated health status: Progressing -> Healthy
```
**Git said 3. Kubernetes briefly said 1. Argo CD noticed and fixed it — without anyone running `kubectl apply`.** That's the entire point of GitOps, demonstrated with a real drift event and a real reconciliation, not asserted.

## Kubernetes + GitOps — final state

```bash
kubectl get application session19-gitops-demo -n argocd -o jsonpath='{.status.sync.status} / {.status.health.status}'
```
```
Synced / Healthy
```

## Final Mental Model

```
METRICS -> numbers        Prometheus
LOGS    -> events         kubectl logs / Loki-class tools
TRACES  -> request journey  (conceptual here - see gap note)

GIT        -> desired state
ARGO CD    -> reconciliation
KUBERNETES -> actual state
```

## Screenshots

*(pending — see the checkpoint note)*
