#!/usr/bin/env bash
# Tears down everything run-demo.sh created, then confirms it's actually gone.
set -uo pipefail
cd "$(dirname "$0")"

kubectl delete -f ingress.yaml --ignore-not-found
kubectl delete -f frontend.yaml --ignore-not-found
kubectl delete -f backend.yaml --ignore-not-found
kubectl delete -f secret.yaml -f configmap.yaml --ignore-not-found

echo
echo "==> Anything left with app=yatri-app?"
kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
kubectl get ingress yatri-ingress 2>&1 || echo "Ingress deleted"
kubectl get deployment yatri-backend yatri-frontend 2>&1 || echo "Deployments deleted"
