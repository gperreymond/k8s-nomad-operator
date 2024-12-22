#/bin/bash

kubectx minikube

kubectl create namespace kestra-system
kubectl create secret generic kestra-postgresql-auth \
    --namespace=kestra-system \
    --from-literal=USER_PASSWORD=changeme

helm repo add kestra https://helm.kestra.io/
helm repo update

helm upgrade --install kestra kestra/kestra \
    --version 0.20.7 \
    --namespace kestra-system \
    --values configs/kestra/values.yaml
