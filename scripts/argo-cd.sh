#/bin/bash

kubectx minikube

kubectl create namespace argo-system

helm upgrade --install argo-cd oci://ghcr.io/argoproj/argo-helm/argo-cd \
    --version 7.7.10 \
    --namespace argo-system \
    --values configs/argo-cd/values.yaml
