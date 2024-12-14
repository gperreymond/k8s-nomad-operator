# K8S NOMAD OPERATOR

## Setup 

```sh
# Install Helm 3 if not installed
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# enter devbox shell
$ devbox shell
# start minikube
$ minikube start --driver=docker --kubernetes-version=v1.31.3
$ minikube ip # grap IP of minikube node
# then edit ".env": example, minikube ip is "192.168.49.2", change ips with the 192.168.49 as prefix
$ kubectx minikube
# use the minikube ip adress to change the two IPs for nomad servers, then
$ docker compose up -d --force-recreate
$ docker compose -f docker-compose.nomad.yaml up -d --force-recreate
# install crossplane
$ kubectl create namespace crossplane-system
$ helm repo add crossplane https://charts.crossplane.io/master/
$ helm install my-crossplane crossplane/crossplane --version 1.19.0-rc.0.130.g528a75077 --namespace crossplane-system --values configs/crossplane/values.yaml
# install crossplane providers
$ kubectl apply -f crossplane/providers
# deploy terraform workspaces
$ kubectl apply -f crossplane/keycloak
$ kubectl apply -f crossplane/keycloak/europe-paris
$ kubectl apply -f crossplane/nomad
$ kubectl apply -f crossplane/nomad/europe-paris
```

* https://marketplace.upbound.io/
* http://traefik.docker.localhost/
* http://keycloak.docker.localhost/
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


