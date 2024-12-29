# K8S NOMAD OPERATOR

## Setup 

```sh
# install devbox, if not installed
$ curl -fsSL https://get.jetify.com/devbox | bash
# install Helm 3, if not installed
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# create external docker network
$ docker network create --driver=bridge --gateway=192.168.49.1 --subnet=192.168.49.0/24 minikube-network
# minikube: start
$ devbox run minikube:start
# docker compose: start
$ devbox run docker-compose:start
# terraform: apply
$ cd terraform
$ terraform init
# only the first time
$ terraform apply -target helm_release.argo_cd
# after that, all classic
$ terraform apply
```

## Utils

```sh
# argo-cd admin password
$ kubectl -n argo-system get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

* https://marketplace.upbound.io/
* http://traefik.docker.localhost/
* http://keycloak.docker.localhost/
* http://minio-webui.docker.localhost/
* http://kestra.docker.localhost/
* http://nomad.europe-paris.docker.localhost/

## Install cni plugins for nomad clients

* https://github.com/containernetworking/plugins

```sh
$ export ARCH_CNI=$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)
$ export CNI_PLUGIN_VERSION=v1.6.1
$ curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGIN_VERSION}/cni-plugins-linux-${ARCH_CNI}-${CNI_PLUGIN_VERSION}".tgz
$ sudo mkdir -p /opt/cni/bin
$ sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
$ rm cni-plugins.tgz
```

## Run nomad client locally

I choose to download the binary into ".bin" directory in this repo.

```sh
$ sudo ./scripts/nomad-client.sh
```

## Documentations

* https://github.com/prometheus-operator/kube-prometheus/
* https://github.com/prometheus-operator/kube-prometheus/blob/v0.14.0/kustomization.yaml
* https://prometheus-operator.dev/
* https://prometheus-operator.dev/docs/platform/thanos/
