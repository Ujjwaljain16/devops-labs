# Deployment Strategies: Blue-Green, Canary & Recreate

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

See [ques.md](ques.md) for exactly what this module covers and why it exists as its own module.

**Environment note:** Same live Minikube cluster (WSL2 Ubuntu) as every other Kubernetes module in this repo.

---

## Part 1: Blue-Green Deployment (`02-blue-green/`)

Two complete, independent environments running simultaneously - Blue and Green - with a Service selector deciding which one actually receives traffic.

```bash
kubectl apply -f deployment-blue.yaml
kubectl apply -f deployment-green.yaml
kubectl get pods -l app=myapp --show-labels
```
```text
app-blue-5b5754954b-8hjn9    1/1   Running   app=myapp,slot=blue
app-blue-5b5754954b-n7vrn    1/1   Running   app=myapp,slot=blue
app-blue-5b5754954b-sf587    1/1   Running   app=myapp,slot=blue
app-green-597bd464bb-bxhl2   1/1   Running   app=myapp,slot=green
app-green-597bd464bb-cw5nc   1/1   Running   app=myapp,slot=green
app-green-597bd464bb-dp2n5   1/1   Running   app=myapp,slot=green
```
6 Pods total, both environments fully up before any traffic decision is made - that's the defining (and expensive) trait of Blue-Green: 2x compute the whole time both exist.

### Route to Blue first

```bash
kubectl apply -f service-blue.yaml
curl -s http://localhost:9080   # port-forwarded to myapp-service
```
```text
service/myapp-service created
<html><body><p>BLUE ENVIRONMENT</p></body></html>
```

### The actual cutover - one Service selector change

```bash
kubectl apply -f service-green.yaml
kubectl get endpoints myapp-service
curl -s http://localhost:9080
```
```text
service/myapp-service configured
NAME            ENDPOINTS
myapp-service   10.244.0.28:80,10.244.0.29:80,10.244.0.30:80

<html><body><p>GREEN ENVIRONMENT</p></body></html>
```
The `Endpoints` object flipped to Green's 3 Pod IPs the instant the Service's `selector` changed - no rolling window, no in-between state where some requests hit Blue and some hit Green. `service-blue.yaml` and `service-green.yaml` are identical except for one line (`slot: blue` vs `slot: green`), which is the entire mechanism.

### Instant rollback - same trick, reversed

```bash
kubectl apply -f service-blue.yaml
curl -s http://localhost:9080
```
```text
service/myapp-service configured
<html><body><p>BLUE ENVIRONMENT</p></body></html>
```
Rollback is just as instant as the forward cutover, because Blue never stopped running - it was sitting there fully warm the entire time Green was live. That's the actual trade Blue-Green makes: pay for double the compute, get an instant, zero-risk switch in both directions.

Cleaned up the inactive Green deployment after confirming rollback worked, then tore down the rest.

---

## Part 2: Canary Deployment (`03-canary/`)

A small fraction of new-version Pods sitting *inside the same Service* as the stable majority, so a slice of real traffic hits the new version before committing to a full rollout.

```bash
kubectl apply -f deployment-stable.yaml   # 9 replicas
kubectl apply -f service.yaml
kubectl rollout status deployment/app-stable --timeout=60s
kubectl apply -f deployment-canary.yaml   # 1 replica
```
```text
NAME                          READY   STATUS    LABELS
app-canary-555c567858-wvp24   1/1     Running   app=myapp-canary,track=canary
app-stable-7f86987f9d-26vdh   1/1     Running   app=myapp-canary,track=stable
app-stable-7f86987f9d-ccnjb   1/1     Running   app=myapp-canary,track=stable
... (7 more stable Pods)
```
10 Pods, one shared `app=myapp-canary` label the Service selects on - `track: stable` vs `track: canary` only exists to tell them apart visually, the Service doesn't care about it at all.

### The traffic-split test - and a real gotcha I hit along the way

First attempt used `kubectl port-forward svc/myapp-canary-service` and looped 20 curls through it - got **20/20 `STABLE v1`, zero canary hits**. That's not the canary failing; `kubectl port-forward` against a Service picks *one* backing Pod for the entire forwarding session and sends everything there, it doesn't load-balance the way real Service traffic does. Redid it from inside the cluster instead, where kube-proxy actually round-robins across every matching Pod:

```bash
kubectl exec dns-test -- sh -c 'for i in $(seq 1 20); do wget -qO- http://myapp-canary-service; echo; done'
```
```text
STABLE v1
STABLE v1
CANARY v2
STABLE v1
... (17 total STABLE v1, 1 total CANARY v2)
```
1 out of 20 - almost exactly the 10% the 9:1 pod ratio predicts.

### Shift the ratio to 30%

```bash
kubectl scale deployment app-canary --replicas=3
kubectl scale deployment app-stable --replicas=7
```
```text
$ kubectl get pods -l app=myapp-canary -L track --no-headers | awk '{print $NF}' | sort | uniq -c
      3 canary
      7 stable

$ kubectl exec dns-test -- sh -c 'for i in $(seq 1 20); do wget -qO- http://myapp-canary-service; echo; done' | sort | uniq -c
      6 CANARY v2
     14 STABLE v1
```
6/20 = 30% - the traffic ratio tracks the pod-count ratio directly, because the Service has no concept of "canary" at all, it's just splitting evenly across whatever Pods currently match its selector.

### Rollback - scale canary to zero

```bash
kubectl scale deployment app-canary --replicas=0
kubectl scale deployment app-stable --replicas=9
```
```text
$ kubectl exec dns-test -- sh -c 'for i in $(seq 1 5); do wget -qO- http://myapp-canary-service; echo; done'
STABLE v1
STABLE v1
STABLE v1
STABLE v1
STABLE v1
```
5/5 stable - the canary rollback is just as cheap as the rollout, one `scale` command either direction.

---

## Part 3: Recreate Deployment (`04-recreate/`)

`strategy.type: Recreate` - kills every old Pod before starting any new ones. Guarantees the two versions never coexist, at the cost of a real downtime window.

```bash
kubectl apply -f deployment-v1.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/app-recreate --timeout=30s
```

### Capturing the outage live

Started a continuous request loop against the Service from inside the cluster, then triggered the v2 update while it was still running:

```bash
kubectl exec dns-test -- sh -c 'i=0; while [ $i -lt 40 ]; do wget -qO- --timeout=1 http://app-recreate-service || echo "[OUTAGE] Connection refused / 0 pods alive"; sleep 0.5; i=$((i+1)); done' &
kubectl apply -f deployment-v2.yaml
```
```text
VERSION: v1
VERSION: v1
VERSION: v1
VERSION: v1
VERSION: v1
VERSION: v1
VERSION: v1
[OUTAGE] Connection refused / 0 pods alive
VERSION: v2 (UPGRADED)
VERSION: v2 (UPGRADED)
VERSION: v2 (UPGRADED)
... (v2 continues)
```
Genuinely caught only **one** `[OUTAGE]` line - with images already cached locally on this single-node Minikube cluster, the gap between "all v1 Pods terminated" and "first v2 Pod ready" was well under a second, so the 0.5s polling loop only landed on it once. On a real multi-node cluster pulling a fresh image over the network, that window would be seconds to minutes long, not sub-second - the mechanism is identical, just the duration depends entirely on how fast the new Pods can actually start. Either way, the outage is real and provable, not simulated.

### Rollout history and rollback

```bash
kubectl rollout history deployment/app-recreate
kubectl rollout undo deployment/app-recreate
kubectl rollout status deployment/app-recreate --timeout=30s
kubectl exec dns-test -- wget -qO- http://app-recreate-service
```
```text
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/app-recreate rolled back
Waiting for deployment "app-recreate" rollout to finish: 0 out of 3 new replicas have been updated...
... (stays at 0 for several checks - Recreate again tearing everything down first)
Waiting for deployment "app-recreate" rollout to finish: 1 of 3 updated replicas are available...
deployment "app-recreate" successfully rolled out
VERSION: v1
```
Worth noting: the rollback *also* went through the full Recreate cycle (all v2 Pods down, then v1 Pods up) - `strategy.type: Recreate` applies to every template change on this Deployment, rollback included. It's not a special "fast path," it's the same mechanism running in reverse.

---

## Interview-style takeaways

- **Why does Blue-Green need 2x the compute but Canary doesn't?** Blue-Green keeps two *complete, independently-sized* environments alive simultaneously so either one can take 100% of traffic instantly. Canary only ever runs a small fraction of the new version - the "extra" cost is proportional to the canary percentage, not a full second environment.
- **Why did the canary traffic ratio match the pod ratio so closely?** Kubernetes Services don't do weighted routing by version - they just distribute evenly across every Pod matching the selector. A 9:1 pod split *is* the traffic split; there's no separate traffic-shaping layer unless you bring one in (like a service mesh or Ingress-level canary annotations).
- **Why did `kubectl port-forward` give a misleading result for the canary test?** It forwards to a single, specific backing Pod for the life of the connection - it's a debugging shortcut, not a stand-in for real Service load-balancing. Testing actual traffic distribution has to go through the Service's real routing (kube-proxy), which only happens for traffic that originates inside the cluster or through the Service's real entrypoint, not through `port-forward`.
- **Why does Recreate exist at all if it causes downtime?** Some changes genuinely cannot have both versions running at once safely - an incompatible database schema migration, an incompatible shared cache format, a breaking API contract change on a singleton resource. Recreate trades availability for the guarantee that v1 and v2 are never both touching shared state simultaneously.
