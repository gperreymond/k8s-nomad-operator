# K8S NOMAD OPERATOR

```sh
# Install cni on my local machine
# https://github.com/containernetworking/plugins/releases
$ mkdir -p .tmp/cni/bin
$ export cni_plugins_version=1.6.1
$ wget https://github.com/containernetworking/plugins/releases/download/v${cni_plugins_version}/cni-plugins-linux-amd64-v${cni_plugins_version}.tgz
# unzip into .tmp/cni/bin
```

```sh
$ devbox shell
$ minikube start --driver=docker --kubernetes-version=v1.31.3
# grap IP of minikube node, example "192.168.49.2"
$ docker inspect minikube | jq -r '.[0].NetworkSettings.Networks.minikube.IPAMConfig.IPv4Address'
$ kubectx minikube
$ kubectl apply -f manifests
$ kubectl apply -f examples
# use the minikube ip adress to change the two IPs for nomad servers, then
$ docker compose up -d --force-recreate
$ docker compose -f docker-compose.nomad-client.yaml up -d --force-recreate
```

* http://traefik.docker.localhost
* http://nomad-europe.docker.localhost
