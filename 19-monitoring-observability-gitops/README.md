# Monitoring, Observability & GitOps

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

The exact task breakdown, my reasoning for running this module on a separate cluster, and my reasoning for using this same repository as the GitOps source are documented in [ques.md](ques.md).

---

# Task 1: Monitoring

## Metrics

I installed Prometheus using Helm (the `prometheus-community/prometheus` chart) and confirmed that it is genuinely scraping eight real targets:
```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
curl -s http://localhost:9090/api/v1/targets | ...
```
```
[kubernetes-api-servers, kubernetes-nodes, kubernetes-nodes-cadvisor,
 kubernetes-service-endpoints x4, prometheus], all reporting health: up
```

## CPU utilization

```bash
curl -s 'http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes'
```
The value returned was `1114935296` bytes (approximately 1.06 GiB) available at query time. This matched the output of `free -h` on the WSL host at the same moment.

## Memory utilization

I used the same query family, `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100`, as a Grafana panel (see the Dashboard section below) rather than as a single one-off query, since memory utilization is something that should be watched continuously rather than checked once.

## Application health

Kubernetes' own readiness and liveness model is the application health primitive that everything else builds on. Module 16's `devsecops-demo` already implements real `readinessProbe` and `livenessProbe` checks against `/health` (see [16-cicd-devsecops/k8s/deployment.yaml](../16-cicd-devsecops/k8s/deployment.yaml)). In this module, the GitOps demo application's health is represented by Argo CD's own `HEALTH STATUS` field, discussed further in Task 3, where it reports `Healthy`, derived from the Deployment's actual `readyReplicas` compared with the desired count.

## Alerts

I wrote two real Prometheus alert rules (`monitoring/prometheus-values.yaml`), and confirmed they were loaded and evaluating:
```bash
curl -s http://localhost:9090/api/v1/rules
```
```
Group: node-health
 - HighNodeMemoryUsage | state: inactive | health: ok
 - NodeExporterDown    | state: inactive | health: ok
```

I did not stop at confirming that the rules existed and evaluated without error. I wanted to see one of them actually fire, so I patched the node-exporter DaemonSet with a `nodeSelector` that would never match, which genuinely took it down:

```bash
kubectl patch daemonset prometheus-prometheus-node-exporter -n monitoring \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"demo-disable":"true"}}}}}'
```

My first attempt at this alert (`up{...} == 0`) never fired, and understanding why turned out to be a genuinely useful finding in its own right. When a Service has zero Endpoints, `kubernetes_sd_configs` drops the target from service discovery entirely rather than reporting `up=0` for it. The metric series does not change to a value of 0; it simply stops existing. I confirmed this directly:
```bash
curl -s 'http://localhost:9090/api/v1/query?query=up{job="kubernetes-service-endpoints",service="prometheus-prometheus-node-exporter"}'
```
```
{"status":"success","data":{"resultType":"vector","result":[]}}
```
The result was empty rather than a value of 0. I corrected the rule to use `absent()` instead, which is the proper way to alert on a target disappearing entirely:
```yaml
- alert: NodeExporterDown
  expr: absent(up{job="kubernetes-service-endpoints", service="prometheus-prometheus-node-exporter"} == 1)
  for: 1m
```
After reloading the configuration, I watched the real state transition end to end:
```
check 1: inactive
check 2: unknown   <- config reload in progress
check 4: pending    <- condition true, waiting out the "for: 1m"
check 6: firing     <- genuinely alerting
```
I then confirmed that the alert had actually reached Alertmanager, and was not only visible to the rule evaluator:
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
I then restored node-exporter by removing the fake `nodeSelector`, and confirmed that the alert genuinely resolved:
```
check 1: firing
check 2: inactive
```
This is the complete real lifecycle of the alert: inactive, then pending, then firing (confirmed in both Prometheus and Alertmanager), then inactive again. It is not a static screenshot of a rule that has never actually been exercised.

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

**Metrics** are numbers recorded over time, such as CPU percentage, request count, or memory in bytes. They are cheap to store and cheap to query, and are well suited to dashboards and alerting thresholds. However, a metric cannot explain why something went wrong; it can only indicate that something did.

**Logs** are discrete, timestamped events, usually written as free text or structured JSON, emitted by the application itself. They are expensive to store at scale, but they carry detail that metrics cannot, such as an exact error message, a stack trace, or a specific request's parameters.

**Traces** record the journey of one specific request across every service it touches, with timing information for each hop. This is the only pillar capable of answering why a particular request was slow in a system composed of more than one service. A metric can indicate that p99 latency increased; a trace can explain that the increase occurred because service B waited 400 milliseconds on a downstream call to service C.

## Why observability is required

Monitoring, as covered in Task 1, tells the operator that something is wrong: an alert fires, or a graph spikes. Observability, by contrast, is what allows a new question, one that was not anticipated in advance, to be answered using data that is already being collected, without writing new code to add further instrumentation. A dashboard is an instance of monitoring. Being able to move from an observation such as "checkout latency has increased" to a conclusion such as "the cause is this one pod, this one dependency, this one query", without adding a single new log line, is observability. The `NodeExporterDown` investigation earlier in this document is a small but real example of this distinction. The alert itself, which is monitoring, fired correctly. Understanding why the naive `up == 0` expression never fired, however, required querying Prometheus's own data directly, which is observability, to discover that the metric series had vanished rather than simply assuming a cause.

## Common tools

| Pillar | Tool used here | Other common tools |
|---|---|---|
| Metrics | Prometheus | Datadog, CloudWatch, InfluxDB |
| Dashboards | Grafana | Datadog, Kibana |
| Logs | `kubectl logs` (at this module's scale) | Loki, ELK/Elasticsearch, Splunk |
| Traces | Not implemented here; see note below | Jaeger, Zipkin, Tempo |
| Alerting | Prometheus Alertmanager | PagerDuty, Opsgenie |

**Limitation:** I did not deploy a real distributed tracing backend such as Jaeger or Tempo for this module. The demonstration application (`nginxdemos/hello`) does not emit trace spans, and adding genuine OpenTelemetry instrumentation to an application built from scratch, purely for this module, felt like more scope than the task required, particularly on an already resource-constrained cluster. I have documented the concept of tracing honestly above rather than presenting a fabricated trace waterfall screenshot.

## Kubernetes observability

Kubernetes exposes all three pillars natively, which is precisely why Prometheus and Grafana function here with almost no custom code.

- **Metrics**: `kube-state-metrics` reports object state such as pod counts and deployment status, `node-exporter` reports host-level CPU, memory, and disk usage, and cAdvisor reports per-container resource usage and is built directly into the kubelet. All three are scraped by Prometheus above and appear as real targets in the target list.
- **Logs**: `kubectl logs` is backed by the container runtime writing stdout and stderr to disk for each container. No separate logging agent is required for basic access, although a production cluster would typically ship these logs to a system such as Loki or the ELK stack for retention beyond a pod's own lifetime.
- **The Kubernetes API as an observability source in its own right**: commands such as `kubectl get events` and `kubectl describe` were already used extensively in [module 13](../13-kubernetes-troubleshooting/README.md), and are used again below to inspect the Argo CD Application's own event stream.

## Dashboard

I created a real Grafana dashboard through the Grafana API itself, rather than assembling it manually in the UI, and confirmed that it is genuinely running and queryable:
```bash
curl -s -X POST http://admin:admin123@localhost:3000/api/dashboards/db -d @monitoring/grafana-dashboard.json
```
```
{"status":"success","uid":"67e98302-0504-44fc-a6f2-9686c74e97da","url":"/d/67e98302-.../session19-cluster-overview"}
```
I then confirmed that the datasource actually works, rather than only that it had been created:
```bash
curl -s http://admin:admin123@localhost:3000/api/datasources/uid/bfzq2i4ngiwaod/health
```
```
{"status":"OK","message":"Successfully queried the Prometheus API."}
```

---

# Task 3: GitOps

## What is GitOps?

Instead of running `kubectl apply` by hand, or from a CI pipeline holding cluster credentials, the cluster runs an agent (Argo CD) that continuously watches a Git repository and makes the cluster match whatever is declared there. Deploying is reduced to a `git push`. Nothing has direct write access to the cluster except the agent itself.

## Git as the source of truth

Describing Git as the source of truth means that if the live cluster and Git ever disagree, Git takes precedence: the cluster is changed to match Git, never the reverse. I demonstrated this concretely in the self-healing section below, where a manual `kubectl scale` change was silently reverted within approximately ten seconds because it disagreed with the state declared in Git.

## Declarative configuration

The manifests in [gitops-app/app/](gitops-app/app/) describe what should exist, such as a Deployment with `replicas: 3` and a Service, and never describe how to reach that state. Argo CD computes the difference between what Git declares and what is actually running, and reconciles the two. Imperative commands such as `kubectl scale` or `kubectl edit` are exactly what GitOps is designed to make unnecessary, and are exactly what get overridden in the demonstration below.

## Continuous reconciliation

Argo CD does not check the cluster once at deploy time and stop. It continues comparing live state to Git state on an ongoing basis, through its poll interval and, as used below, through an on-demand refresh annotation. With `selfHeal: true` enabled, it acts on every difference it finds, not only the first one.

## GitOps workflow: the repository used

I used this same repository rather than a separate one. [gitops-app/app/](gitops-app/app/) holds the manifests, and [gitops-app/argocd-application.yaml](gitops-app/argocd-application.yaml) is the Argo CD `Application` resource pointing at that exact path. I kept this file one level outside `app/` so that it is never mistaken for a workload manifest to be synced.

### Steps 1 and 2: cluster and Argo CD installation

```bash
minikube start -p session19 --cpus=2 --memory=1800mb
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
I encountered a real and fairly common issue immediately: the `applicationsets.argoproj.io` CRD's annotations exceed etcd's 256KB limit for the last-applied-configuration annotation under a plain `kubectl apply`. The proper fix, rather than a workaround, was to use server-side apply, which does not rely on that annotation at all. This produced a client conflict on the second apply, arising from mixing client-side and server-side ownership, which I resolved using `--force-conflicts`. All seven Argo CD pods came up cleanly after that.

### Steps 3 to 5: Git repository, Application, and first sync

```bash
kubectl apply -f gitops-app/argocd-application.yaml
kubectl get applications -n argocd
```
```
NAME                    SYNC STATUS   HEALTH STATUS
session19-gitops-demo   Synced        Healthy
```
This matches the reference project's expected output exactly.

### Step 6: checking Kubernetes

```bash
kubectl get all -n session19-gitops
```
```
pod/gitops-demo-6d98947cf8-9mkl7   1/1   Running
pod/gitops-demo-6d98947cf8-p276d   1/1   Running
deployment.apps/gitops-demo   2/2   2   2
```

### Step 7: changing replicas in Git and watching it propagate

I edited `gitops-app/app/deployment.yaml`, changing `replicas` from `2` to `3`, then committed and pushed the change for real to `Ujjwaljain16/devops-labs`. I triggered an immediate refresh using the `argocd.argoproj.io/refresh=hard` annotation rather than waiting out Argo CD's default poll interval of approximately three minutes:
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
The change travelled from Git to Argo CD to Kubernetes. This is the essence of GitOps.

### Step 8: self-healing

```bash
kubectl scale deployment gitops-demo -n session19-gitops --replicas=1
```
```
NAME          READY   UP-TO-DATE   AVAILABLE
gitops-demo   2/3     3            2
```
A pod was already mid-termination when this output was captured. I polled the deployment every ten seconds, and it had already returned to `3/3` by the first check:
```
check 1: replicas=3 ready=3
```
The real event trail, taken directly from `kubectl describe application`, explains why:
```
OperationStarted    Initiated automated sync to '8ebc37e...'
ResourceUpdated     Updated sync status: Synced -> OutOfSync      <- my manual kubectl scale created drift
OperationCompleted  Partial sync operation to 8ebc37e... succeeded
ResourceUpdated     Updated sync status: OutOfSync -> Synced       <- reverted back to Git's declared state
ResourceUpdated     Updated health status: Progressing -> Healthy
```
Git declared three replicas. Kubernetes briefly showed one. Argo CD detected the discrepancy and corrected it without anyone running `kubectl apply`. This is the entire point of GitOps, demonstrated here through a real drift event and a real reconciliation, rather than simply asserted.

## Kubernetes and GitOps: final state

```bash
kubectl get application session19-gitops-demo -n argocd -o jsonpath='{.status.sync.status} / {.status.health.status}'
```
```
Synced / Healthy
```

## Final mental model

```
METRICS -> numbers        Prometheus
LOGS    -> events         kubectl logs / Loki-class tools
TRACES  -> request journey  (conceptual here, see limitation noted above)

GIT        -> desired state
ARGO CD    -> reconciliation
KUBERNETES -> actual state
```

## Screenshots

Argo CD Application `Synced`/`Healthy`, the full monitoring stack Running, and the GitOps-managed Deployment at its final `3/3` state, captured after self-healing:

![Argo CD status, monitoring pods, and final deployment state](screenshots/01_argocd_and_monitoring.png)

### A second real screenshot pass

The original `session19` profile was deleted after this module was finished, to free disk space on this machine. For a later submission-readiness pass, I rebuilt the entire stack from scratch on a fresh `session19` profile, using the exact same real files already in this folder (`monitoring/prometheus-values.yaml`, `monitoring/grafana-dashboard.json`, `gitops-app/`), and re-ran the real alert and GitOps lifecycles end to end, not just redeployed the stack and left it idle.

Alert rules loaded and `inactive` on a completely fresh Prometheus install:
![Alert rules freshly loaded, both inactive](screenshots/02_alert_rules_inactive.png)

I then broke `node-exporter` the same way as the original run (a `nodeSelector` patch that never matches) and watched the real transition: `inactive` at t=0, `pending` by t=20s, `firing` by t=80s, confirmed in Alertmanager's own `/api/v2/alerts` with a real `startsAt` timestamp. Restoring node-exporter needed one extra real fix this time: a plain strategic-merge `kubectl patch` only adds keys to `nodeSelector`, it does not remove them, so the fake `demo-disable` key stayed behind until I used `kubectl patch --type=json` with an explicit `remove` operation. Once removed, the alert genuinely resolved: `firing` for about a minute while waiting on the next evaluation cycle, then `inactive`, and Alertmanager's `/api/v2/alerts` returned `[]`.

Argo CD, installed fresh with the same `--server-side --force-conflicts` fix as the original (the CRD-size issue did not reproduce this time, which can happen depending on which Argo CD `stable` build is current when the manifest is fetched), synced the real `gitops-app/` from GitHub immediately to `3/3`, since `replicas: 3` was already the committed state from the original run. I re-ran the self-healing demo instead of the initial-sync demo: `kubectl scale --replicas=1`, then polled the Deployment, which was already back to `2/3` within 10 seconds and fully `3/3` within 20, with the same drift-detected-and-corrected event trail as the original (`Synced -> OutOfSync -> Synced`, `Healthy -> Progressing -> Healthy`) confirmed via `kubectl describe application`.

Final composite state after both real lifecycles, independent of the original run:
![Final composite state, second pass](screenshots/03_final_composite_state.png)

<img width="1024" height="567" alt="image" src="https://github.com/user-attachments/assets/ffa0bd87-844a-4ebd-91b9-5a51439f9212" />


The entire `session19` profile was deleted again immediately after capturing this, consistent with the free-tier-style discipline used for the AWS modules: nothing stays running just to look impressive later.
