#!/usr/bin/env bash
# Deploys the whole Yatri stack: ConfigMap + Secret + backend + frontend + Ingress.
# Assumes Minikube is running and the ingress addon is already enabled.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> 1/5 ConfigMap + Secret"
kubectl apply -f configmap.yaml -f secret.yaml

echo "==> 2/5 Backend (Deployment + Service, multi-document YAML)"
kubectl apply -f backend.yaml

echo "==> 3/5 Frontend (Deployment + Service, multi-document YAML)"
kubectl apply -f frontend.yaml

echo "==> 4/5 Waiting for both Deployments"
kubectl rollout status deployment/yatri-backend --timeout=120s
kubectl rollout status deployment/yatri-frontend --timeout=120s

echo "==> 5/5 Ingress"
kubectl apply -f ingress.yaml

echo
echo "==> Full stack:"
kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
