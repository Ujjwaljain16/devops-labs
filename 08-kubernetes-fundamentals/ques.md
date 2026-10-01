# Assignment - Kubernetes Fundamentals
---

## 1. What's required

- Read the official Kubernetes architecture docs (`kubernetes.io/docs/concepts/architecture/`) and cross-check against class notes
- Install Minikube locally
- Install the `kubectl` CLI
- Verify Minikube works (`minikube start`, then `minikube status`)
- Walk through "Deploy an application" from the Kubernetes Basics tutorial (`kubernetes.io/docs/tutorials/kubernetes-basics/`) using the Hello Minikube example

## 2. Notes

Docker and Docker Compose are not covered again here, since they were already handled in modules [05](../05-docker-fundamentals/README.md) through [07](../07-docker-networking-and-volumes/README.md) of this repository. Writing actual Pod, ReplicaSet, or Deployment YAML manifests, and topics such as DaemonSets, deeper networking, or scaling and rollback scenarios, are also explicitly not part of this assignment; they belong to later modules.

## 3. My completion checklist

- [x] Read the official Kubernetes architecture docs and cross-checked them against the lecture's component breakdown
- [x] Can identify control-plane components: etcd, API server, scheduler, controller manager
- [x] Can identify worker-node components: kubelet, kube-proxy, CRI (containerd)
- [x] Understand the Pod to Node to Cluster relationship and the principle that everything goes through the API server
- [x] kubectl installed and working
- [x] Minikube installed
- [x] `minikube start` works
- [x] `minikube status` confirms the local cluster is healthy
- [x] Looked at the Hello Minikube docs
- [x] Ran the Hello Minikube "Deploy an application" example end-to-end, including hitting the running service with curl
- [x] Checked Pod labels, used `kubectl exec` to run real commands inside the container, and cleaned up the Deployment afterward rather than leaving it running
- [x] Screenshots: cluster verification, live service response, labels/exec/cleanup
