# Kubernetes Probes: Liveness, Readiness, Startup

The instructor's Session 13 folder has a dedicated Probes section (`05-probes/`: three manifests and a guide). The tracking doc's task list never mentions it, so I treated the manifests and the guide as the brief and ran every exercise in it for real, including the two "try breaking it" ones.

The three manifests, [`liveness.yaml`](liveness.yaml), [`readiness.yaml`](readiness.yaml) and [`startup.yaml`](startup.yaml), are the instructor's, unchanged (I verified they are byte-identical to the originals). The two files [`liveness-broken.yaml`](liveness-broken.yaml) and [`readiness-broken.yaml`](readiness-broken.yaml) are mine: each is the original with **one line** changed (`path: /` to `path: /wrong-path`), exactly the edit the guide asks for.

Cluster: Minikube (Kubernetes v1.37.0), `default` namespace, image `nginx:1.27`. All outputs below are from real runs on 7 and 8 October 2026.

## The three probes in one table

| Probe | The question | What a failure does | What I observed |
|---|---|---|---|
| **Startup** | "Have you finished starting?" | Holds the other two probes off until it passes | `startup-demo`: 1/1 Ready, 0 restarts |
| **Readiness** | "Can I send you traffic?" | Pod becomes `NotReady`, leaves the Service endpoints, **container is not restarted** | `readiness-demo`: `0/1 Running`, endpoints empty, `restartCount=0` |
| **Liveness** | "Are you still healthy?" | Kubelet **kills and restarts** the container | `liveness-demo`: restarts climbing, `CrashLoopBackOff` |

## 1. The healthy baseline

```bash
kubectl apply -f liveness.yaml -f readiness.yaml -f startup.yaml
kubectl wait --for=condition=ready pod/liveness-demo pod/readiness-demo pod/startup-demo --timeout=180s
kubectl get pod liveness-demo readiness-demo startup-demo
```
```text
NAME             READY   STATUS    RESTARTS   AGE
liveness-demo    1/1     Running   0          6s
readiness-demo   1/1     Running   0          6s
startup-demo     1/1     Running   0          6s
```
The probe configuration each Pod really carries (from `kubectl describe pod`):
```text
liveness-demo:   Liveness:  http-get http://:80/ delay=5s timeout=2s period=5s #success=1 #failure=3
readiness-demo:  Readiness: http-get http://:80/ delay=5s timeout=1s period=5s #success=1 #failure=3
startup-demo:    Liveness:  http-get http://:80/ delay=0s timeout=1s period=5s #success=1 #failure=3
                 Readiness: http-get http://:80/ delay=0s timeout=1s period=5s #success=1 #failure=3
                 Startup:   http-get http://:80/ delay=0s timeout=1s period=2s #success=1 #failure=30
```
Note the `startup-demo` numbers: the startup probe checks every 2s and tolerates 30 failures, which is **up to 60 seconds** for the app to start, during which the liveness and readiness probes do not run at all. That is the whole point of it: a slow-booting app is not killed by an impatient liveness probe. (nginx starts in well under a second, so here it passes on the first check. The 20-second slow-start version of this idea, with a real before/after, is in [module 09](../../09-kubernetes-pods-replicasets-deployments/README.md), Task 1, item 09.)

## 2. Readiness: `Running` is not the same as `Ready`

The guide exposes the Pod through a Service and looks at its endpoints:
```bash
kubectl expose pod readiness-demo --name=readiness-service --port=80
kubectl get endpoints readiness-service
```
```text
NAME                ENDPOINTS        AGE
readiness-service   10.244.0.22:80   2s          <- exactly the Pod's own IP (10.244.0.22)
```

### Try breaking it

The guide says to change the readiness path to `/wrong-path` and `kubectl apply` again. Doing exactly that against the running Pod does **not** work:
```text
$ kubectl apply -f readiness-broken.yaml
The Pod "readiness-demo" is invalid: spec: Forbidden: pod updates may not change fields other than
`spec.containers[*].image`,`spec.initContainers[*].image`,`spec.activeDeadlineSeconds`,
`spec.tolerations` (only additions to existing tolerations),`spec.terminationGracePeriodSeconds`...
@@ -136,7 +136,7 @@
    "ReadinessProbe": {
-     "Path": "/",
+     "Path": "/wrong-path",
```
**Finding:** probes cannot be edited on a running bare Pod. The API server rejects the update, and the live Pod keeps its original `/` path (I checked with `jsonpath`). The guide's instruction only works for a Pod you delete and recreate. (A Deployment would roll out new Pods for you, which is one more reason not to run bare Pods.) So:
```bash
kubectl delete pod readiness-demo --wait=true
kubectl apply -f readiness-broken.yaml
sleep 25
kubectl get pod readiness-demo
kubectl get endpoints readiness-service
kubectl describe pod readiness-demo | tail -6
kubectl get pod readiness-demo -o jsonpath='restartCount={.status.containerStatuses[0].restartCount}'
```
```text
NAME             READY   STATUS    RESTARTS   AGE
readiness-demo   0/1     Running   0          25s

NAME                ENDPOINTS   AGE
readiness-service               46s            <- the endpoints list is now EMPTY

  Normal   Started    25s               kubelet            Container started
  Warning  Unhealthy  5s (x4 over 20s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404

restartCount=0
```
This is the key point of the whole exercise, in one screen: the Pod is `STATUS Running` (the process is alive and nginx is serving), but `READY 0/1`, so the Service has **no endpoints** and would send it no traffic. And `restartCount=0`: the kubelet did not touch the container, because **readiness failure is not a restart.**

## 3. Liveness: failure means a restart

Same story for the break: `kubectl apply -f liveness-broken.yaml` over the running Pod is rejected with the same `Forbidden` error, so I deleted the Pod and recreated it from the broken manifest. Watching it live:
```bash
kubectl get pod liveness-demo -w
```
```text
NAME            READY   STATUS             RESTARTS      AGE
liveness-demo   1/1     Running            4 (30s ago)   95s
liveness-demo   1/1     Running            5 (0s ago)    115s
liveness-demo   0/1     CrashLoopBackOff   5 (0s ago)    2m15s
```
The restart count climbs on a steady rhythm (about every 20 seconds: a 5s initial delay plus 3 failed checks 5s apart), and then the status turns to `CrashLoopBackOff` as Kubernetes starts spacing the restarts out. (Compare this with module 09, where on this same cluster the status column kept saying `Error` for a crashing container instead of the textbook name: the label that appears is not always the same.) `kubectl describe pod liveness-demo` explains it:
```text
  Warning  Unhealthy  53s (x18 over 3m1s)  kubelet  Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    53s (x6 over 2m49s)  kubelet  Container nginx failed liveness probe, will be restarted
  Warning  BackOff    52s (x4 over 2m2s)   kubelet  Back-off restarting failed container nginx in pod liveness-demo_default(...)

    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
```
The sequence is exactly the one the guide describes: `Unhealthy` (the probe sees a 404, which counts as a failure; only 200-399 is healthy), then `Killing ... will be restarted`, then `BackOff`.

One detail that surprised me: the container's last state is `Completed` with **exit code 0**, not an error. A liveness kill is a graceful SIGTERM, and nginx obeys it and exits cleanly. Compare the `OOMKilled` / exit code 137 of [module 09](../../09-kubernetes-pods-replicasets-deployments/README.md)'s memory-limit demo, which is a hard SIGKILL from the kernel. Same visible result (a restart), different cause, different exit code, which is why the exit code is worth reading.

### Screenshot: both broken Pods, about 20 minutes after they were created

![readiness-demo and liveness-demo, both broken, plus the mini-project resources](../screenshots/02_probes_and_mini_project_state.png)

The top half of this capture is the two probe failures side by side, taken later in the session when both Pods had been failing for a while: `readiness-demo` is **`0/1 Running`**, `readiness-service` has **empty endpoints**, and the event is `Unhealthy (x185 over 20m) ... Readiness probe failed: HTTP probe failed with statuscode: 404`; `liveness-demo` is **`0/1 CrashLoopBackOff`** with 11 restarts, and its events show `Killing ... failed liveness probe, will be restarted`, `Unhealthy (x21) ... statuscode: 404` and `BackOff`. (The bottom half is the mini project's resources, covered in [03-mini-project](../03-mini-project/README.md).)

One honest note on that image: `readiness-demo` shows `RESTARTS 1 (20m ago)`. That is **not** the probe restarting the container (a readiness failure never does that). The `SandboxChanged ... Pod sandbox changed, it will be killed and re-created` event right above it, 20 minutes earlier, is my Minikube cluster being restarted. When I measured right after creating the Pod (section 2), `restartCount` was `0`.

## 4. Debugging a failing probe (guide section 14)

The guide's method: look at the events, then go inside and try the probe's request yourself. The events were above; for the inside look I used the healthy `startup-demo` Pod (the broken liveness Pod was between restarts, and `kubectl exec` answered `container not found`):
```bash
kubectl exec startup-demo -- curl -s -o /dev/null -w "%{http_code}" http://localhost:80/
kubectl exec startup-demo -- curl -s -o /dev/null -w "%{http_code}" http://localhost:80/wrong-path
```
```text
GET /            -> http 200   (the probe path: passes, 200-399 means healthy)
GET /wrong-path  -> http 404   (what the broken probe sees: 404 means failure)
```
This shows the cause directly: the probe is not "broken", it is faithfully reporting that the path it was told to check really does return 404. (The nginx image has `curl`, but not `wget`, which the guide's example uses.)

## What I took away

- `Running` only means the process is alive. `Ready` is a separate verdict, and it is the one that decides whether the Pod gets traffic.
- A failed **readiness** probe pulls the Pod out of the Service and leaves the container alone (`restartCount=0`). A failed **liveness** probe restarts it. Confusing the two is the classic mistake: a too-strict liveness probe on a slow app creates a restart loop, which is what the startup probe exists to prevent.
- The probe fields of a bare Pod are immutable. To change a probe you recreate the Pod (or, properly, change a Deployment and let it roll).
- When a probe fails, read the events first (`kubectl describe pod`), then reproduce the probe's request from inside the container. The status column alone does not tell you why.

## Cleanup

```bash
kubectl delete pod liveness-demo readiness-demo startup-demo
kubectl delete service readiness-service
```
