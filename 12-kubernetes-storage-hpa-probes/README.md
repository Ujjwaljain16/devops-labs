# Kubernetes Storage, HPA & Probes

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for the exact task breakdown. Task 1 (Volumes) is written up separately in [01-kubernetes-volumes/README.md](01-kubernetes-volumes/README.md), since the doc explicitly asked for a dedicated sub-README there. Task 2 (HPA) is below. Task 3 (the Mini Project) is in [03-mini-project/README.md](03-mini-project/README.md) and the dedicated Probes work is in [04-probes/README.md](04-probes/README.md); both are summarised at the bottom of this file.Task 3 (Mini Project) is blocked; see the note at the bottom.

---

## Task 2: HPA Hands-on

### Step 0: enable metrics-server

HPA reads CPU utilization from the Metrics API, which nothing serves until `metrics-server` is running. The `metrics-server` addon was not enabled on this cluster by default, so I enabled it below as the first step. Without it, `kubectl top` and any HPA just sit at `<unknown>` forever.

```bash
minikube addons enable metrics-server
kubectl top nodes
```
```
* The 'metrics-server' addon is enabled

NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
minikube   209m         5%       1021Mi          26%
```

### Step 1: deploy the application

I used `registry.k8s.io/hpa-example` (the standard `php-apache` image from the official Kubernetes HPA walkthrough), since it exposes an endpoint that runs a CPU-burning loop, which makes it easy to generate real load. I set `resources.requests.cpu` on the container, which is mandatory, because HPA's percentage target (`averageUtilization`) is computed against the request, so without one the HPA has nothing to divide by.

```yaml
# 02-hpa/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hpa-demo-app
  template:
    metadata:
      labels:
        app: hpa-demo-app
    spec:
      containers:
        - name: php-apache
          image: registry.k8s.io/hpa-example
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 200m
            limits:
              cpu: 500m
---
apiVersion: v1
kind: Service
metadata:
  name: hpa-demo-app
spec:
  selector:
    app: hpa-demo-app
  ports:
    - port: 80
      targetPort: 80
```

```bash
kubectl apply -f deployment.yaml
kubectl wait --for=condition=Available deployment/hpa-demo-app --timeout=90s
```
```
deployment.apps/hpa-demo-app created
service/hpa-demo-app created
deployment.apps/hpa-demo-app condition met
```

### Step 2 & 3: configure HPA, verify it

```yaml
# 02-hpa/hpa.yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-demo-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

```bash
kubectl apply -f hpa.yml
kubectl get hpa hpa-demo-app
```

Right after creation the target reads `<unknown>`, since metrics-server had not completed its first scrape cycle against this specific pod yet:

```
horizontalpodautoscaler.autoscaling/hpa-demo-app created
NAME           REFERENCE                 TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo-app   Deployment/hpa-demo-app   cpu: <unknown>/50%   1         5         1          21s
```

I ran `kubectl describe hpa`, which confirmed exactly why: `FailedGetResourceMetric: did not receive metrics for targeted pods`, a transient state rather than a real error:

```
Conditions:
  Type           Status  Reason                   Message
  ----           ------  ------                   -------
  AbleToScale    True    SucceededGetScale        the HPA controller was able to get the target's current scale
  ScalingActive  False   FailedGetResourceMetric  the HPA was unable to compute the replica count: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
```

About a minute later, real metrics showed up and the HPA started reporting genuine utilization:

```bash
kubectl get hpa hpa-demo-app
```
```
NAME           REFERENCE                 TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo-app   Deployment/hpa-demo-app   cpu: 0%/50%   1         5         1          99s
```

### Step 4-7: load generator, rising CPU, Pod scaling

```yaml
# 02-hpa/load-generator.yaml
apiVersion: v1
kind: Pod
metadata:
  name: load-generator
spec:
  containers:
    - name: load-generator
      image: busybox:1.36
      command:
        - sh
        - -c
        - "while true; do wget -q -O- http://hpa-demo-app.default.svc.cluster.local; done"
  restartPolicy: Never
```

```bash
kubectl apply -f load-generator.yaml
```

I polled `kubectl get hpa` and `kubectl top pods` every approximately 25 seconds for about 3.5 minutes to watch it happen live:

```
=== 12:46:07 UTC (check 1/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 0%/50%   1   5   1   111s
hpa-demo-app-6f95889dc-skf6n   1m   10Mi

=== 12:46:33 UTC (check 2/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 0%/50%   1   5   1   2m18s
hpa-demo-app-6f95889dc-skf6n   160m   13Mi

=== 12:47:00 UTC (check 3/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 80%/50%   1   5   2   2m44s
hpa-demo-app-6f95889dc-skf6n   160m   13Mi

=== 12:47:26 UTC (check 4/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 80%/50%   1   5   2   3m10s
hpa-demo-app-6f95889dc-skf6n   160m   13Mi

=== 12:47:52 UTC (check 5/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 173%/50%   1   5   2   3m37s
hpa-demo-app-6f95889dc-gtqzq   327m   11Mi
hpa-demo-app-6f95889dc-skf6n   366m   13Mi

=== 12:48:19 UTC (check 6/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 173%/50%   1   5   5   4m4s
hpa-demo-app-6f95889dc-gtqzq   327m   11Mi
hpa-demo-app-6f95889dc-skf6n   366m   13Mi

=== 12:48:46 UTC (check 7/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 93%/50%   1   5   5   4m30s
hpa-demo-app-6f95889dc-gtqzq   201m   11Mi
hpa-demo-app-6f95889dc-sg4ml   145m   11Mi
hpa-demo-app-6f95889dc-skf6n   225m   13Mi
hpa-demo-app-6f95889dc-x6qng   185m   12Mi
hpa-demo-app-6f95889dc-ztzqd   180m   11Mi

=== 12:49:13 UTC (check 8/8) ===
hpa-demo-app   Deployment/hpa-demo-app   cpu: 93%/50%   1   5   5   4m57s
(5 pods, same as above)
```

Reading straight off that log shows what actually happened. CPU sat at 0% with nothing hitting the app, then climbed to 80% within approximately 30 seconds of the load generator starting, comfortably over the 50% target, so the HPA scaled to 2 replicas. Load kept climbing (173% against a now-doubled capacity), so it kept scaling, capping out at `maxReplicas: 5`. The 5 pods then settled around 93%, still over target but pinned at the max I configured.

### Step 8: capturing the output from HPA's own event log

I ran `kubectl describe hpa` again after it had leveled off, and it showed the full scaling history in the `Events` section, including three real `SuccessfulRescale` events rather than just the polling snapshots above:

```bash
kubectl describe hpa hpa-demo-app
```
```
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  77% (155m) / 50%
Min replicas:                                          1
Max replicas:                                          5
Deployment pods:                                       5 current / 5 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooManyReplicas   the desired replica count is more than the maximum replica count
  ScaledToZero    False   NotScaledToZero   the HPA controller did not scale the workload to zero
Events:
  Type     Reason                        Age                    From                       Message
  Warning  FailedGetResourceMetric       5m29s                  horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedComputeMetricsReplicas  5m29s                  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: unable to get metrics for resource cpu: no metrics returned from resource metrics API
  Warning  FailedGetResourceMetric       4m27s (x4 over 5m13s)  horizontal-pod-autoscaler  failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Warning  FailedComputeMetricsReplicas  4m27s (x4 over 5m13s)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready)
  Normal   SuccessfulRescale             3m9s                   horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             2m6s                   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             111s                   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
```

One detail worth calling out is that the HPA jumped straight to 4 replicas on its second rescale rather than 3. This is the HPA's own scale-up algorithm being aggressive on purpose, since it can roughly double the replica count in one step when utilization is far over target rather than crawling up by one, which is exactly what the 173%/50% ratio above triggered.

I cleaned up the load generator afterward so the cluster would not keep burning CPU:

```bash
kubectl delete pod load-generator
```
```
pod "load-generator" deleted
```

The HPA will now scale back down toward `minReplicas: 1` on its own once CPU stays under target for the default 5-minute stabilization window. I did not wait for that, since the scale-*up* behavior, the actual ask, is fully captured above.

### Screenshots

`kubectl get hpa` and `kubectl get pods` at the settled state, showing 5/5 Running with the HPA holding at 5 replicas:

![HPA scaled to 5 replicas, all pods Running](screenshots/01_hpa_scaled_to_5_replicas.png)

---

## Task 3: Mini Project

The doc's Session 13 tab says only *"Complete the mini project provided for Session 13"* and attaches nothing, so I first marked this as blocked rather than invent a project. The brief was in the instructor's reference repository all along (`session-13-storage-hpa-probes/mini-project/`), and I should have looked there first.

It is one nginx Deployment that combines this session's three topics: a PVC mounted at `/data`, an HPA between 2 and 5 replicas at 50% CPU, and startup, readiness and liveness probes, in its own `production-webapp` namespace. I ran the instructor's five manifests unchanged and verified each claim of the brief. The full write-up, with real outputs, is in [03-mini-project/README.md](03-mini-project/README.md). The results in short:

- **Storage:** the PVC bound in 3 seconds through dynamic provisioning. A file written through one Pod was readable from a replacement, and, as a stronger test, from two brand-new Pods after I scaled to **zero**, with the claim `Bound` the whole time.
- **HPA, up:** it was blind (`<unknown>`) for the first minutes of a fresh cluster while metrics-server warmed up. With six load generators it scaled `2 -> 3 -> 4` in the first run and `2 -> 4` in one step in the second run, and **stopped at 4, not 5**: each Pod sat at about 53% of its request, inside the HPA's 10 percent tolerance, so 4 is the stable answer. (The brief's example log ends at 5, but that is an illustration.)
- **HPA, down:** after I removed the load at 12:59:27 UTC the metric fell to `1%` within three minutes, but the replicas stayed at 4 until about 13:06:13, the default 5-minute stabilization window, and then dropped to 2.
- **Bonus challenge 2:** a wrong readiness path on the real Deployment left both Pods `Running` but `0/1`, the Service with no endpoints and a real request failing with `Connection refused`, and because the manifest uses `strategy: Recreate` the old healthy Pods were already gone.

## Task 4: Probes (a dedicated section)

The session is called "Storage, HPA & **Probes**", but the doc's task list never breaks Probes out, and I had marked the topic as unresolved. The instructor's repository has a dedicated `05-probes/` folder with three manifests and a guide, so I ran all of it, including both "try breaking it" exercises. The write-up is in [04-probes/README.md](04-probes/README.md). In short:

- **Readiness:** a wrong path leaves the Pod `Running` but `0/1`, the Service endpoints empty, and `restartCount=0`. A readiness failure takes a Pod out of traffic without restarting it.
- **Liveness:** a wrong path makes the kubelet kill and restart the container (restarts climbing, then `CrashLoopBackOff`). The container's last state is `Completed` with exit code 0, a graceful SIGTERM, unlike the exit code 137 of an out-of-memory kill.
- **A finding the guide does not mention:** the guide says to edit the path and `kubectl apply` again, but the API server **rejects that for a running Pod** (probe fields are immutable on a bare Pod). The Pod has to be deleted and recreated.
