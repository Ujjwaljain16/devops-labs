# Kubernetes Ingress, ConfigMaps & Secrets

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for the exact breakdown of what was required

**Environment note:** Same WSL2 (Ubuntu) environment and Docker Desktop engine as previous modules, using the local Minikube cluster. Every command below was run in that WSL Ubuntu shell.

---

## Task 1: Pod Lifecycle States (`pod-lifecycle/`)

All 12 files applied in numeric order, each inspected with `get pods`, `describe pod`, and `logs` before moving to the next.

### 01 - Running

```bash
kubectl apply -f 01-running-pod.yaml
kubectl get pods -o wide
```
```text
pod/running-demo created
NAME           READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
running-demo   1/1     Running   0          15s   10.244.0.4   minikube   <none>           <none>
```
`kubectl logs running-demo` came back with a full nginx startup log (worker processes, epoll event method, etc.) - confirms a Running Pod actually has a live, log-producing container behind it.

### 02 - Pending

```bash
kubectl apply -f 02-pending-pod.yaml
kubectl describe pod pending-demo
```
```text
pod/pending-demo created
NAME           READY   STATUS    RESTARTS   AGE
pending-demo   0/1     Pending   0          5s

Events:
  Warning  FailedScheduling  6s  default-scheduler  0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory.
```
`kubectl logs pending-demo` returns nothing useful - makes sense, there's no container to have logs yet, the scheduler never even placed it on the node. Deleted it right after since a deliberately-unschedulable Pod has nothing more to show.

### Screenshot Verification (Running + Pending)
![Running and Pending Pods](screenshots/01_pod_lifecycle_running_pending.png)

### 03 & 04 - Succeeded and Failed

```bash
kubectl apply -f 03-succeeded-pod.yaml
kubectl apply -f 04-failed-pod.yaml
```
```text
NAME             READY   STATUS      RESTARTS   AGE
failed-demo      0/1     Error       0          16s
succeeded-demo   0/1     Completed   0          17s
```
```text
$ kubectl logs succeeded-demo
Task started
Task completed successfully

$ kubectl logs failed-demo
Simulating a task failure
```
Both confirm the doc's point exactly: logs stay readable after the container exits, regardless of whether it exited 0 (`Completed`) or non-zero (`Error`/`Failed`).

### Screenshot Verification (Succeeded + Failed)
![Succeeded and Failed Pods](screenshots/02_pod_lifecycle_succeeded_failed.png)

### 05 - CrashLoopBackOff

```bash
kubectl apply -f 05-crashloopbackoff-pod.yaml
```
```text
$ kubectl get pod crashloop-demo
NAME             READY   STATUS   RESTARTS       AGE
crashloop-demo   0/1     Error    5 (115s ago)   3m31s

$ kubectl describe pod crashloop-demo | tail -5
Warning  BackOff    53s (x4 over 2m21s)  kubelet  Back-off restarting failed container crasher in pod crashloop-demo_default(...)
```
Worth calling out honestly: on this Minikube/kubelet version the `STATUS` column kept showing `Error` between restart attempts rather than the literal string `CrashLoopBackOff`, even though the actual mechanism is 100% there - restart count climbing (0→5), and the `Warning BackOff … Back-off restarting failed container` event, which is the real signature of the backoff loop growing exponentially (10s, 20s, 40s...). Didn't fudge the column text to match the textbook name; documenting what the cluster actually showed.

### 06 - Image Pull Failure

```bash
kubectl apply -f 06-image-pull-failure-pod.yaml
```
```text
$ kubectl get pod image-pull-failure-demo
NAME                      READY   STATUS             RESTARTS   AGE
image-pull-failure-demo   0/1     ImagePullBackOff   0          79s

$ kubectl describe pod image-pull-failure-demo | tail -6
Warning  Failed   Failed to pull image "nginx:this-tag-does-not-exist-v99": ... not found
Warning  Failed   Error: ErrImagePull
Normal   BackOff  Back-off pulling image "nginx:this-tag-does-not-exist-v99"
Warning  Failed   Error: ImagePullBackOff
```
This one does show the exact progression the doc describes: `ErrImagePull` first attempt, then `ImagePullBackOff` once kubelet starts backing off retries.

### Screenshot Verification (CrashLoopBackOff + Image Pull Failure)
![CrashLoop and Image Pull Failure](screenshots/03_pod_lifecycle_crashloop_imagepull.png)

### 07 - Readiness Probe

```bash
kubectl apply -f 07-readiness-probe-pod.yaml
```
```text
$ kubectl get pod readiness-demo
NAME              READY   STATUS    RESTARTS   AGE
readiness-demo   0/1     Running   0          108s

$ kubectl describe pod readiness-demo | tail -1
Warning  Unhealthy  1s (x16 over 75s)  kubelet  Readiness probe failed: cat: can't open '/tmp/ready': No such file or directory
```
This is the container distinct from Pending: it's genuinely `Running` (process is alive), just permanently `0/1` because the readiness check never passes - proves readiness and "container running" are two separate signals, not the same thing.

### 08 - Liveness Probe

```bash
kubectl apply -f 08-liveness-probe-pod.yaml
```
The container touches `/tmp/healthy`, holds it for 30s, deletes it, then the liveness probe (checking every 5s) fails and kubelet restarts the container:
```text
$ kubectl get pod liveness-demo
NAME            READY   STATUS    RESTARTS     AGE
liveness-demo   1/1     Running   1 (8s ago)   73s

$ kubectl describe pod liveness-demo | tail -5
Warning  Unhealthy  38s  kubelet  Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
Normal   Killing    38s  kubelet  Container healthcheck-demo failed liveness probe, will be restarted
```
Caught the exact `Unhealthy → Killing → restart` sequence live.

### 09 - Startup Probe

```bash
kubectl apply -f 09-startup-probe-pod.yaml
```
The container doesn't create its "started" marker for 20s. The `livenessProbe` alone (`periodSeconds: 2`, `failureThreshold: 3` → would kill at ~6s) would murder this container before it ever finishes starting - the `startupProbe` (`periodSeconds: 5`, `failureThreshold: 10` → up to 50s grace) is what holds liveness checks off until the app is actually up:
```text
$ kubectl get pod startup-demo
NAME            READY   STATUS    RESTARTS   AGE
startup-demo   1/1     Running   0          53s
```
No restarts, ever - confirms the startup probe did its job of shielding the slow boot from the aggressive liveness check.

### 10 - Init Container

```bash
kubectl apply -f 10-init-container-pod.yaml
```
```text
$ kubectl describe pod init-container-demo
Init Containers:
  setup:
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
    Ready:          True

$ kubectl logs init-container-demo -c setup
Running setup steps before the app starts
Setup complete
```
Init container ran to completion *before* the main `nginx` container ever started - visible directly in the separate `Init Containers:` block, plus you have to pass `-c setup` to `logs` since it's a distinct container within the same Pod.

### 11 - Multi-Container (Sidecar)

```bash
kubectl apply -f 11-multi-container-pod.yaml
```
```text
$ kubectl get pod multi-container-demo
NAME                    READY   STATUS    RESTARTS   AGE
multi-container-demo   2/2     Running   0          107s

$ kubectl logs multi-container-demo -c log-sidecar --tail=5
Thu Sep 17 13:39:59 UTC 2026 - app is alive
Thu Sep 17 13:40:04 UTC 2026 - app is alive
Thu Sep 17 13:40:09 UTC 2026 - app is alive
```
`2/2 Ready` - both containers in one Pod, sharing the `emptyDir` volume. The sidecar (`log-sidecar`) is tailing a file it never wrote itself, only the `app` container did - proving the shared-volume communication actually works between the two.

### Screenshot Verification (Readiness, Liveness, Startup, Init Container, Multi-Container)
![Probes, Init Container and Multi-Container Pods](screenshots/04_pod_lifecycle_probes_init_multi.png)

All five applied together and re-checked ~50s later: `readiness-demo` still permanently `0/1`, `init-container-demo`/`startup-demo`/`multi-container-demo` all healthy, and at this exact poll `liveness-demo` hadn't hit its restart yet (`RESTARTS 0` at 51s - the restart lands a little after this, as shown separately above). Left it in rather than re-timing a "cleaner" screenshot, since that's what actually happened at that moment.

### 12 - Graceful Termination

```bash
kubectl delete pod graceful-termination-demo --wait=true
```
```text
pod "graceful-termination-demo" deleted from default namespace
Elapsed: 17s
```
`terminationGracePeriodSeconds: 30` + a `preStop` hook that sleeps 15s before letting the container actually stop - the delete took ~17s wall-clock instead of disappearing instantly, which is the entire point of a graceful shutdown: nginx gets a real window to drain in-flight connections instead of being SIGKILLed mid-request.

### Screenshot Verification (Graceful Termination, live watch)
![Graceful Termination Watch](screenshots/05_pod_lifecycle_graceful_termination.png)
Caught mid-flight: `Running` → `Terminating` (still `1/1` since the `preStop` hook is mid-sleep) → the delete confirmation lands → the watch stream then replays the last known `Completed` state a few times before settling, which is just `kubectl -w` re-emitting the final cached state rather than anything new happening.

### Bonus - `hello.yaml`: Watching the Transient States Live, Not Just the End Result

`03-succeeded-pod.yaml` above already proves a batch Pod reaches `Completed`, but that only shows the *final* state - it doesn't prove the in-between stages actually happen. Ran a separate `hello.yaml` (deliberately with a longer sleep so a live watcher has time to actually catch `Running` before it flips) with `kubectl get pods -w` already running before `apply`:

```bash
kubectl apply -f hello.yaml
```
```text
pod/hello-pod created
NAME        READY   STATUS              RESTARTS   AGE
hello-pod   0/1     Pending             0          0s
hello-pod   0/1     Pending             0          0s
hello-pod   0/1     ContainerCreating   0          0s
hello-pod   0/1     ContainerCreating   0          1s
hello-pod   1/1     Running             0          1s
hello-pod   0/1     Completed           0          8s
```
All three named transitions live: `Pending → ContainerCreating → Running → Completed`, caught mid-flight rather than just spot-checked at the end.
```text
$ kubectl logs hello-pod
hello from a short-lived task
done
```

---

## Task 2: `yatri-backend-rs` ReplicaSet - Deploy & Scale

```bash
kubectl apply -f replicaset/yatri-backend-rs.yaml
kubectl get rs yatri-backend-rs
```
```text
replicaset.apps/yatri-backend-rs created
NAME               DESIRED   CURRENT   READY   AGE
yatri-backend-rs   3         3         3       8s
```
3/3 confirmed. Then the scaling practice:

```bash
kubectl scale rs/yatri-backend-rs --replicas=5
```
```text
NAME               DESIRED   CURRENT   READY   AGE
yatri-backend-rs   5         5         5       19s
```

```bash
kubectl scale rs/yatri-backend-rs --replicas=1
```
```text
NAME               DESIRED   CURRENT   READY   AGE
yatri-backend-rs   1         1         1       33s
```

```bash
kubectl scale rs/yatri-backend-rs --replicas=3
```
```text
NAME               DESIRED   CURRENT   READY   AGE
yatri-backend-rs   3         3         3       39s
```
Every scale operation reconciled within a handful of seconds - the ReplicaSet controller just kept comparing desired vs. actual replica count and creating/deleting Pods to match, exactly the "reconciliation loop" concept from the lecture.

### Self-healing - manually kill a Pod, watch the controller replace it

Scaling proves the controller reacts to a changed desired count; this proves it reacts to *drift* even when nobody touched the desired count at all:

```bash
POD=$(kubectl get pods -l app=yatri-backend-rs -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD
kubectl get pods -l app=yatri-backend-rs
```
```text
Deleting yatri-backend-rs-dclwh
pod "yatri-backend-rs-dclwh" deleted from default namespace
NAME                     READY   STATUS    RESTARTS   AGE
yatri-backend-rs-smfmj   1/1     Running   0          21s
yatri-backend-rs-x6v2r   1/1     Running   0          21s
yatri-backend-rs-xhrts   1/1     Running   0          5s
```
`yatri-backend-rs-dclwh` is gone for good - it's not coming back. Instead, a brand-new Pod (`yatri-backend-rs-xhrts`, a completely different name) appeared 4 seconds later, because the ReplicaSet controller's reconciliation loop noticed `CURRENT` (2) had dropped below `DESIRED` (3) and immediately created a replacement. Deleted the standalone RS afterward (`kubectl delete -f yatri-backend-rs.yaml`) so its `app: yatri-backend-rs` selector wouldn't sit around next to the Deployment's `app: yatri-backend` Pods.

### Screenshot Verification (ReplicaSet create → scale to 5 → delete)
![ReplicaSet Scaling](screenshots/06_replicaset_scaling.png)
Notice the Pod names: the 3 original Pods (`5ljcw`, `lc2dv`, `rbp6d`) stay alive across the scale-up, and only 2 *new* Pods (`7d689`, `hkc4s`) get added to reach 5 - the ReplicaSet controller tops up the difference rather than recreating everything from scratch.

---

## Task 3: Deployment v1 - Deploy, `get all`, Scale to 5

```bash
kubectl apply -f deployments/deployment-v1.yaml
kubectl get all -o wide
```
```text
deployment.apps/yatri-backend created
service/yatri-backend-svc created
NAME                                 READY   STATUS    RESTARTS   AGE
pod/yatri-backend-589d686699-5rwrc   1/1     Running   0          8s
pod/yatri-backend-589d686699-9r65k   1/1     Running   0          8s
pod/yatri-backend-589d686699-z6h8h   1/1     Running   0          8s

NAME                        TYPE        CLUSTER-IP       PORT(S)   AGE
service/yatri-backend-svc   ClusterIP   10.102.253.226   80/TCP    8s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/yatri-backend   3/3     3            3           8s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/yatri-backend-589d686699   3         3         3       8s
```
One `kubectl apply` on the Deployment manifest cascaded into all three of Deployment → ReplicaSet → Pods, plus the bundled Service - the full ownership chain the lecture title points at, visible in a single `get all`.

```bash
kubectl scale deployment yatri-backend --replicas=5
kubectl get pods -l app=yatri-backend
```
```text
NAME                             READY   STATUS    RESTARTS   AGE
yatri-backend-589d686699-5rwrc   1/1     Running   0          19s
yatri-backend-589d686699-9r65k   1/1     Running   0          19s
yatri-backend-589d686699-bsb6m   1/1     Running   0          6s
yatri-backend-589d686699-vsnrj   1/1     Running   0          6s
yatri-backend-589d686699-z6h8h   1/1     Running   0          19s
```
5/5 confirmed - `kubectl scale` on a Deployment just passes the new replica count down to the ReplicaSet it owns, same mechanism as Task 2, one layer up.

### Screenshot Verification (Deployment v1 → `get all` → scale to 5)
![Deployment v1 get all and scale](screenshots/07_deployment_v1_get_all.png)
This screenshot is from re-running the whole Task 3 sequence fresh for the screenshot pass, so `deployment.apps/yatri-backend configured` shows instead of `created` (the Deployment already existed from the transcript run above), and `get all` shows *both* ReplicaSets side by side - the freshly-rebuilt `589d686699` (`nginx:1.25-alpine`, the v1 image) at 3/3, and the older `77ff77b7c7` (`nginx:1.27-alpine`, the v2 image from the earlier transcript run) sitting at `0/0/0`. That's genuine Deployment revision history, not a mistake - it's exactly the same "old ReplicaSet kept around for rollback" behavior documented in the Final Cluster State section below.

---

## Task 4: Deployment v2 - Rolling Update, Watched Live

Applied `deployment-v2.yaml` (image bump `nginx:1.25-alpine` → `nginx:1.27-alpine`, explicit `maxSurge: 1` / `maxUnavailable: 1`, `replicas: 3`) on top of the still-running v1, with `kubectl get pods -w` running in parallel:

### Screenshot Verification (watch terminal, moment before triggering the update)
![Pre-rollout baseline](screenshots/08_deployment_v2_rollout_baseline.png)
Being honest about what this one actually shows: it's terminal A's `kubectl get pods -w` right after starting, still just the 5 steady `589d686699` (v1) Pods - the `kubectl apply -f deployment-v2.yaml` in terminal B hadn't landed yet when this was captured, so it's the *baseline* state rather than the live transition. The actual mid-rollout transition (old Pods `Terminating` while new ones come up) is the transcript captured live further below, from my own run.

```bash
kubectl apply -f deployments/deployment-v2.yaml
```
```text
deployment.apps/yatri-backend configured
service/yatri-backend-svc unchanged
```

Live watch output (trimmed to the meaningful transitions):
```text
yatri-backend-589d686699-vsnrj   1/1     Terminating         0          16s
yatri-backend-589d686699-bsb6m   1/1     Terminating         0          16s
yatri-backend-77ff77b7c7-gm2gb   0/1     Pending             0          0s
yatri-backend-77ff77b7c7-gm2gb   0/1     ContainerCreating   0          0s
yatri-backend-589d686699-5rwrc   1/1     Terminating         0          29s
yatri-backend-77ff77b7c7-n7nr5   0/1     Pending             0          0s
yatri-backend-589d686699-5rwrc   0/1     Completed           0          29s
yatri-backend-77ff77b7c7-gm2gb   1/1     Running             0          9s
yatri-backend-589d686699-9r65k   1/1     Terminating         0          38s
yatri-backend-77ff77b7c7-gf9qz   0/1     Pending             0          0s
yatri-backend-77ff77b7c7-gf9qz   1/1     Running             0          0s
yatri-backend-589d686699-z6h8h   1/1     Terminating         0          38s
```
Exactly what `maxSurge`/`maxUnavailable` describe on paper: old (`589d686699`) Pods terminating a couple at a time, never all 5 at once, while new (`77ff77b7c7`) Pods come up in their place - no downtime window where zero Pods were serving.

```bash
kubectl rollout status deployment/yatri-backend
kubectl get deployment yatri-backend
```
```text
deployment "yatri-backend" successfully rolled out
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
yatri-backend   3/3     3            3           60s
```

One thing worth calling out honestly rather than glossing over: the Deployment ended at **3** replicas, not the 5 I'd scaled it to in Task 3. That's because `deployment-v2.yaml` declares `replicas: 3`, and `kubectl apply` on a declarative manifest overwrites whatever the imperative `kubectl scale` had set - the 5-replica state from Task 3 was never written back into the YAML, so reapplying any manifest without `replicas: 5` in it reverts the count. Real, useful lesson about declarative vs. imperative drift, not just a scripted "everything worked" outcome.

```bash
kubectl get deployment yatri-backend -o jsonpath='{.spec.template.spec.containers[0].image}'
```
```text
nginx:1.27-alpine
```
Confirms the rollout actually landed on the v2 image, not just that the rollout command exited 0.

---

## Task 5: Controlled-Failure Troubleshooting

### `selector-mismatch.yaml`

```bash
kubectl apply -f troubleshooting/selector-mismatch.yaml
```
```text
The Deployment "broken-selector-demo" is invalid: spec.template.metadata.labels: Invalid value: {"app":"broken-selector-demo-typo"}: `selector` does not match template `labels`
```
This one doesn't even get past `kubectl apply` - the API server itself rejects a Deployment whose `spec.selector` doesn't match `spec.template.metadata.labels` before anything is created. No ReplicaSet, no Pods, nothing to clean up. Good to know this fails fast at admission time rather than silently creating orphaned objects.

**Then actually fixed it** rather than stopping at "here's the error" - [`selector-mismatch-fixed.yaml`](troubleshooting/selector-mismatch-fixed.yaml) is identical except the template label is corrected to match the selector:
```bash
kubectl apply -f troubleshooting/selector-mismatch-fixed.yaml
kubectl get pods -l app=broken-selector-demo
```
```text
deployment.apps/broken-selector-demo created
NAME                                    READY   STATUS    RESTARTS   AGE
broken-selector-demo-665c455b8f-f47kj   1/1     Running   0          6s
broken-selector-demo-665c455b8f-mr7h7   1/1     Running   0          6s
```
Same manifest, one label corrected, `2/2 Running` - confirms the fix, not just the diagnosis.

### `broken-image.yaml`

```bash
kubectl apply -f troubleshooting/broken-image.yaml
kubectl get pods -l app=broken-image-demo
kubectl rollout status deployment/broken-image-demo --timeout=5s
```
```text
deployment.apps/broken-image-demo created
NAME                               READY   STATUS             RESTARTS   AGE
broken-image-demo-6dd8898b-2nv52   0/1     ImagePullBackOff   0          25s
broken-image-demo-6dd8898b-fp8r9   0/1     ImagePullBackOff   0          25s

Waiting for deployment "broken-image-demo" rollout to finish: 0 of 2 updated replicas are available...
error: timed out waiting for the condition
```
```text
$ kubectl describe pod -l app=broken-image-demo | grep -A4 Events:
Normal   BackOff    kubelet  Back-off pulling image "nginx:this-image-tag-absolutely-does-not-exist-404"
Warning  Failed     kubelet  Error: ImagePullBackOff
```
Unlike the selector mismatch, this one *does* create the Deployment/ReplicaSet/Pods just fine - the objects are valid, it's only the actual image pull at runtime that fails, which is exactly why `rollout status` hangs instead of erroring immediately: Kubernetes has no way to know upfront that an image tag doesn't exist in the registry. Deleted it after confirming the failure mode (`kubectl delete -f troubleshooting/broken-image.yaml`).

### `broken-image.yaml` - the actual recovery drill, done properly

The version above deploys the broken image with nothing to fall back to. Redid it as a real recovery scenario instead: deploy a genuinely healthy [`broken-image-v1.yaml`](troubleshooting/broken-image-v1.yaml) first, confirm it's rolled out and healthy, *then* push a broken [`broken-image-v2.yaml`](troubleshooting/broken-image-v2.yaml) over it, and prove the old Pods survive the failed rollout untouched:

```bash
kubectl apply -f troubleshooting/broken-image-v1.yaml
kubectl rollout status deployment/broken-image-recover-demo --timeout=30s
# ... successfully rolled out, 2/2 nginx:1.25-alpine ...

kubectl apply -f troubleshooting/broken-image-v2.yaml
kubectl get pods -l app=broken-image-recover-demo
```
```text
NAME                                         READY   STATUS         RESTARTS   AGE
broken-image-recover-demo-6c747dd869-mgkhg   0/1     ErrImagePull   0          15s
broken-image-recover-demo-86c46f87f4-hx2hj   1/1     Running        0          22s
broken-image-recover-demo-86c46f87f4-jxp8h   1/1     Running        0          22s
```
Exactly the "surge, don't replace" behavior a rolling update is supposed to guarantee: both original `86c46f87f4` Pods are still `Running` untouched, and only the one *new*, surged `6c747dd869` Pod is broken. `kubectl rollout status` confirms it's genuinely stuck, not just slow:
```text
$ kubectl rollout status deployment/broken-image-recover-demo --timeout=8s
Waiting for deployment "broken-image-recover-demo" rollout to finish: 1 out of 2 new replicas have been updated...
error: timed out waiting for the condition
```

**Recovery - `kubectl rollout undo`, not a manual delete:**
```bash
kubectl rollout undo deployment/broken-image-recover-demo
kubectl rollout status deployment/broken-image-recover-demo --timeout=30s
```
```text
deployment.apps/broken-image-recover-demo rolled back
deployment "broken-image-recover-demo" successfully rolled out
NAME                                         READY   STATUS        RESTARTS   AGE
broken-image-recover-demo-6c747dd869-mgkhg   0/1     Terminating   0          30s
broken-image-recover-demo-86c46f87f4-hx2hj   1/1     Running       0          37s
broken-image-recover-demo-86c46f87f4-jxp8h   1/1     Running       0          37s
```
The broken Pod is `Terminating`, the two originals were never touched, and the image confirms it landed back on the known-good tag:
```text
$ kubectl get deployment broken-image-recover-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
nginx:1.25-alpine
```
This is the actual point of `rollout undo` over just deleting the broken Deployment: it's a one-command revert to the last known-good ReplicaSet, with zero Pod downtime for the replicas that were already healthy.

### Screenshot Verification (both controlled-failure scenarios back to back)
![Selector Mismatch and Broken Image Failures](screenshots/09_troubleshooting_selector_and_broken_image.png)
Same terminal, run one after the other: the `selector-mismatch.yaml` rejection at `apply` time, immediately followed by `broken-image.yaml` actually creating its Deployment and landing both replicas in `ImagePullBackOff` before being cleaned up - the fail-fast-vs-fail-at-runtime contrast from the writeup above, side by side in one screenshot.

---

## Task 6: Resource Requests & Limits - CPU Throttling and Memory OOMKill

The instructor mentioned there's a separate assessment/problem-solving exercise for this topic but didn't hand out its actual questions in the transcript - so rather than leave this as pure theory, I built the two failure scenarios myself and reproduced both mechanisms for real: CPU getting throttled under a tight limit, and a container getting OOMKilled for exceeding its memory limit.

**Requests vs. limits, in one line:** `requests` is what the scheduler uses to decide *if* a Pod fits on a node; `limits` is what the kernel actually enforces once it's running. A Pod can be scheduled fine on `requests` and still get punished later for going over `limits` - they're checked at two completely different times by two completely different mechanisms.

### CPU limit exceeded → throttling (not killing)

```yaml
# resource-limits/cpu-throttle-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-throttle-demo
spec:
  containers:
    - name: stress
      image: polinux/stress
      command: ["stress"]
      args: ["--cpu", "2", "--timeout", "300s"]
      resources:
        requests:
          cpu: "100m"
        limits:
          cpu: "200m"
```

Two CPU-hungry worker threads (`--cpu 2`), each trying to peg a full core, crammed into a 200m (0.2 of one core) limit - deliberately starved by 10x.

```text
$ kubectl apply -f cpu-throttle-pod.yaml
pod/cpu-throttle-demo created

$ kubectl get pod cpu-throttle-demo
NAME                READY   STATUS    RESTARTS   AGE
cpu-throttle-demo   1/1     Running   0          20s
```

Notice it's happily `Running`, `0` restarts - CPU throttling doesn't kill or restart anything, it just slows the container down. Minikube doesn't have `metrics-server` running by default so `kubectl top` wasn't an option; instead I read the real enforcement mechanism directly from the container's own cgroup:

```text
$ kubectl exec cpu-throttle-demo -- cat /sys/fs/cgroup/cpu.stat
usage_usec 4778642
user_usec 4688314
system_usec 90328
nr_periods 239
nr_throttled 238
throttled_usec 38536158
```

`nr_periods 239` / `nr_throttled 238` means the container got throttled in 238 out of 239 scheduling periods - essentially every single one - and `throttled_usec` shows ~38.5 seconds of accumulated throttled time. That's the actual kernel CFS bandwidth controller enforcing the 200m limit against two threads that together wanted 2 full cores. Confirmed the limit was really what I set it to, not a typo, before cleaning up:

```text
$ kubectl describe pod cpu-throttle-demo | grep -A2 Limits:
    Limits:
      cpu:  200m
```

### Memory limit exceeded → OOMKilled (crash-loop)

```yaml
# resource-limits/memory-oomkill-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-oomkill-demo
spec:
  containers:
    - name: stress
      image: polinux/stress
      command: ["stress"]
      args: ["--vm", "1", "--vm-bytes", "300M", "--vm-hang", "0"]
      resources:
        requests:
          memory: "50Mi"
        limits:
          memory: "100Mi"
```

One worker deliberately trying to hold 300M of memory against a hard 100Mi limit:

```text
$ kubectl apply -f memory-oomkill-pod.yaml
pod/memory-oomkill-demo created

$ kubectl get pod memory-oomkill-demo   # ~15s later
NAME                  READY   STATUS             RESTARTS      AGE
memory-oomkill-demo   0/1     CrashLoopBackOff   1 (17s ago)   22s
```

Completely different failure mode from CPU: this one's already restarting. Confirmed the actual reason directly:

```text
$ kubectl describe pod memory-oomkill-demo | grep -A4 "Last State"
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
      Started:      Thu, 17 Sep 2026 14:42:24 +0000
      Finished:     Thu, 17 Sep 2026 14:42:24 +0000
```

`Exit Code 137` = `128 + 9` = killed by `SIGKILL` - the kernel's OOM killer, triggered the instant the cgroup's memory usage crossed 100Mi, not a graceful shutdown. Checked again a bit later:

```text
$ kubectl get pod memory-oomkill-demo
NAME                  READY   STATUS      RESTARTS      AGE
memory-oomkill-demo   0/1     OOMKilled   3 (30s ago)   55s
```

Restart count climbing (1 → 3), and this time the `STATUS` column actually does show the literal string `OOMKilled` - a nice contrast with the `05-crashloopbackoff-pod.yaml` case back in Task 1, where this same Minikube/kubelet version only ever showed `Error` instead of the textbook `CrashLoopBackOff` string. Same underlying restart-loop mechanism, different visible label depending on *why* the container died - worth remembering that the STATUS column's exact wording isn't fully consistent across failure causes.

### Screenshot Verification (CPU Throttling cgroup stats + Memory OOMKilled)
![Resource Requests and Limits - CPU Throttle and OOMKill](screenshots/10_resource_limits_cpu_throttle_and_oomkill.png)
Re-ran both demos fresh for this screenshot, so the numbers differ slightly from the transcript above but tell the same story: `nr_periods 122` / `nr_throttled 122` - throttled in *every single period* this time - and the same `OOMKilled` / `Exit Code: 137` on the memory pod. One cosmetic note: the terminal prompt still shows this module's old folder path (`09-kubernetes-pod-lifecycle-replicasets-deployments`), since this was captured before the module got renamed to match the session's official title - the commands and cluster state are identical either way, only the folder name changed afterward.

---

## Task 7: Theoretical Writeup

Covering the concepts that came up throughout this module but deserve their own clear explanation rather than being buried inline.

### The 4 ports, and how a request actually flows through them

```
Client Browser ──► [nodePort: 30080] (Host IP, every node)
                        │
                        ▼
                   [port: 8080] (Service's own virtual IP)
                        │
                        ▼
                   [targetPort: 80] (routes into a Pod)
                        │
                        ▼
                   [containerPort: 80] (the process actually listening)
```
- **`containerPort`** - declared in the Pod spec, purely informational/documentation for what the app inside the container actually listens on. Kubernetes doesn't enforce it; it's `targetPort` that actually has to match it for traffic to land correctly.
- **`targetPort`** - on the Service, the port on the *Pod* that traffic gets forwarded to. This is the piece that has to line up with whatever the container is really listening on.
- **`port`** - the port the Service itself exposes, internally, as its own stable virtual IP. Other things inside the cluster talk to the Service on this port, not `targetPort` directly.
- **`nodePort`** - only exists for `type: NodePort` (or `LoadBalancer`) Services. A static port (`30000-32767`) opened on *every* node's real IP, so something outside the cluster can reach in without needing a cloud load balancer.

### Labels vs. Selectors

**Labels** are just key-value metadata attached to an object (`app: yatri-backend`, `tier: backend`) - they don't *do* anything by themselves, they're just tags. **Selectors** are the query a controller or Service uses to find which objects its labels apply to (`matchLabels: {app: yatri-backend}`). Every ReplicaSet/Deployment/Service in this module works because of that pairing: the controller's `selector` finds Pods by label, and Task 5's `selector-mismatch.yaml` broke *specifically* because the selector and the template's labels stopped agreeing with each other.

### The 4 deployment strategies

- **RollingUpdate** (what Task 4 actually demonstrated) - replaces old Pods with new ones gradually, governed by `maxSurge`/`maxUnavailable`. Zero downtime if configured sanely, but both versions run simultaneously for a window.
- **Recreate** - kills every old Pod first, *then* starts new ones. Guaranteed to never run both versions at once, at the cost of a real downtime window while zero Pods exist. Necessary when two versions genuinely cannot coexist (e.g. an incompatible DB schema migration).
- **Blue-Green** - two complete, independent environments running side by side (old = Blue, new = Green), and a single atomic switch (usually a Service selector change) flips 100% of traffic at once. Instant rollback (flip the selector back), but needs 2x the compute the whole time both environments exist.
- **Canary** - a small fraction of new-version Pods sit alongside the stable majority under the same Service, so a small slice of real traffic hits the new version before committing to a full rollout. Lets you catch problems on a fraction of users instead of everyone at once.

### `maxSurge` vs. `maxUnavailable` - the actual math

For `replicas: 3`, `maxSurge: 1`, `maxUnavailable: 1` (exactly what `deployment-v2.yaml` in Task 4 uses):
- **Max Pods that can exist at once during rollout:** `3 + maxSurge(1) = 4`
- **Min Pods that must stay available at all times:** `3 - maxUnavailable(1) = 2`

That's precisely what the live watch output in Task 4 showed - old Pods terminating a couple at a time, never all 5 (this module was running 5 replicas going into that rollout) at once, always leaving at least 2 available.

### Resource Requests vs. Limits, and GB vs. GiB

Already proved both failure mechanisms hands-on in Task 6, but to state the distinction plainly: **requests** are what the *scheduler* uses to decide whether a Pod fits on a node at all - a promise of "this much is reserved for you." **Limits** are what the *kernel* (via cgroups) actually enforces once the container is running - cross a CPU limit and you get throttled (Task 6's `nr_throttled` proof), cross a memory limit and the container gets `OOMKilled` (Task 6's `Exit Code: 137` proof). They're checked at two completely different times, by two completely different mechanisms.

On units: **1 GB = 10⁹ bytes** (decimal/SI, what marketing and storage vendors use), while **1 GiB = 2³⁰ bytes = 1,073,741,824 bytes** (binary/IEC). Kubernetes deliberately uses the binary units - `Mi` and `Gi` - specifically so there's no ambiguity about which one a manifest means; `100Mi` in Task 6's memory limit is exactly 104,857,600 bytes, not a rounded marketing number.

---

## Final cluster state

```text
$ kubectl get all
NAME                                   READY   STATUS    RESTARTS   AGE
pod/yatri-backend-77ff77b7c7-gf9qz     1/1     Running   0          74s
pod/yatri-backend-77ff77b7c7-gm2gb     1/1     Running   0          83s
pod/yatri-backend-77ff77b7c7-n7nr5     1/1     Running   0          83s

NAME                        TYPE        CLUSTER-IP       PORT(S)   AGE
service/yatri-backend-svc   ClusterIP   10.102.253.226   80/TCP    112s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/yatri-backend   3/3     3            3           112s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/yatri-backend-589d686699   0         0         0       112s
replicaset.apps/yatri-backend-77ff77b7c7   3         3         3       83s
```
Left the v2 Deployment running as the end state of the assignment. The old `589d686699` ReplicaSet is still there at `0/0/0` - Kubernetes keeps it around (by default, last 10 revisions) purely so `kubectl rollout undo` has something to roll back to, which is a detail worth remembering for whenever rollback actually comes up.
