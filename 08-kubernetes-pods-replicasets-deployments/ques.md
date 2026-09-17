# Assignment - Kubernetes Pods, ReplicaSets & Deployments
---

## 1. What's actually required

- Read the official Kubernetes architecture docs (`kubernetes.io/docs/concepts/architecture/`) and cross-check against class notes
- Install Minikube locally
- Install `kubectl` CLI
- Verify Minikube works (`minikube start`, then `minikube status`)
- Walk through "Deploy an application" from the Kubernetes Basics tutorial (`kubernetes.io/docs/tutorials/kubernetes-basics/`) using the Hello Minikube example

## 2. Explicitly NOT part of this assignment

- Docker / Docker Compose recap (already covered in modules [05](../05-docker-fundamentals/README.md)–[07](../07-docker-networking-and-volumes/README.md) of this repo)
- Writing actual Pod / ReplicaSet / Deployment YAML manifests
- DaemonSets, deeper networking, scaling/rollback scenarios

## 3. My completion checklist

- [x] Read the official Kubernetes architecture docs and cross-checked against the lecture's component breakdown
- [x] Can identify control-plane components: etcd, API server, scheduler, controller manager
- [x] Can identify worker-node components: kubelet, kube-proxy, CRI (containerd)
- [x] Understand the Pod → Node → Cluster relationship and the "everything goes through the API server" flow
- [x] kubectl installed and working
- [x] Minikube installed
- [x] `minikube start` works
- [x] `minikube status` confirms the local cluster is healthy
- [x] Looked at the Hello Minikube docs
- [x] Ran the Hello Minikube "Deploy an application" example end-to-end, including hitting the running service with curl

