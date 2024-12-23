#/bin/bash

kubectx minikube

kubectl create namespace terraform-system
kubectl create namespace crossplane-system

helm repo add crossplane https://charts.crossplane.io/master/
helm repo update
helm upgrade --install crossplane crossplane/crossplane \
    --version 1.19.0-rc.0.142.ge485783b6 \
    --namespace crossplane-system \
    --values helm/crossplane/values.yaml
