# K8S NOMAD OPERATOR

## Setup 

```sh
# Install Helm 3 if not installed
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# enter devbox shell
$ devbox shell
# start minikube
$ minikube start --driver=docker --kubernetes-version=v1.31.3
$ minikube addons enable ingress
$ minikube ip # grap IP of minikube node
# then edit ".env": example, minikube ip is "192.168.49.2", change ips with the 192.168.49 as prefix
$ kubectx minikube
# use the minikube ip adress to change the two IPs for nomad servers, then
$ docker compose up -d --force-recreate
$ docker compose -f docker-compose.nomad.yaml up -d --force-recreate
# install crossplane
$ kubectl create namespace terraform-system
$ kubectl create namespace crossplane-system
$ helm repo add crossplane https://charts.crossplane.io/master/
$ helm upgrade --install crossplane crossplane/crossplane --version 1.19.0-rc.0.130.g528a75077 --namespace crossplane-system --values configs/crossplane/values.yaml
# install kestra
$ helm repo add kestra https://helm.kestra.io/
$ kubectl create namespace kestra-system
$ kubectl create secret generic kestra-config --namespace=kestra-system --from-literal=application-kestra.yml=
$ kubectl create secret generic kestra-postgresql-auth \
    --namespace=kestra-system \
    --from-literal=ADMIN_PASSWORD=superchangeme \
    --from-literal=USER_PASSWORD=changeme
$ helm upgrade --install kestra kestra/kestra --version 0.20.7 --namespace kestra-system --values configs/kestra/values.yaml
# install argo-cd
$ kubectl create namespace argo-system
$ helm upgrade --install argo-cd oci://ghcr.io/argoproj/argo-helm/argo-cd --version 7.7.10 --namespace argo-system --values configs/argo-cd/values.yaml
# install manifests
$ kubectl apply -f manifests/argo-system
# install crossplane providers
$ kubectl apply -f crossplane/providers
# deploy terraform workspaces
$ kubectl apply -f crossplane/keycloak
$ kubectl apply -f crossplane/keycloak/europe-paris
$ kubectl apply -f crossplane/nomad
$ kubectl apply -f crossplane/nomad/europe-paris
```

```sh
# argo-cd admin password
$ kubectl -n argo-system get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

* https://marketplace.upbound.io/
* http://traefik.docker.localhost/
* http://keycloak.docker.localhost/
* http://kestra.docker.localhost/
* http://nomad.europe-paris.docker.localhost/

## Install cni plugins for nomad clients

```sh
$ export ARCH_CNI=$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)
$ export CNI_PLUGIN_VERSION=v1.6.1
$ curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGIN_VERSION}/cni-plugins-linux-${ARCH_CNI}-${CNI_PLUGIN_VERSION}".tgz
$ sudo mkdir -p /opt/cni/bin
$ sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
$ rm cni-plugins.tgz
```


