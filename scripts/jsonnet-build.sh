#!/bin/bash

rm -rf build
mkdir -p build/manifests/setup
jsonnet -J vendor -m build/manifests kube-prometheus.jsonnet | xargs -I{} sh -c 'cat {} | ~/go/bin/gojsontoyaml > {}.yaml' -- {}
find build/manifests -type f ! -name '*.yaml' -delete

output_dir="charts/remote-charts/prometheus-operator/manifests"
rm -rf $output_dir
mkdir -p $output_dir
mv build/manifests/prometheus-operator-*.yaml $output_dir
mv build/manifests/setup/prometheus-operator-*.yaml $output_dir
echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $output_dir/kustomization.yaml
echo "kind: Kustomization" >> $output_dir/kustomization.yaml
echo "resources:" >> $output_dir/kustomization.yaml
for file in $output_dir/prometheus-operator-*.yaml; do
  echo "[INFO] add $file to kustomization.yaml"
  if [ -f "$file" ]; then
    echo "  - $(basename "$file")" >> $output_dir/kustomization.yaml
  fi
done

output_dir="charts/remote-charts/prometheus/manifests"
rm -rf $output_dir
mkdir -p $output_dir
mv build/manifests/prometheus-*.yaml $output_dir
echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $output_dir/kustomization.yaml
echo "kind: Kustomization" >> $output_dir/kustomization.yaml
echo "resources:" >> $output_dir/kustomization.yaml
for file in $output_dir/prometheus-*.yaml; do
  echo "[INFO] add $file to kustomization.yaml"
  if [ -f "$file" ]; then
    echo "  - $(basename "$file")" >> $output_dir/kustomization.yaml
  fi
done

output_dir="charts/remote-charts/alert-manager/manifests"
rm -rf $output_dir
mkdir -p $output_dir
mv build/manifests/alertmanager-*.yaml $output_dir
echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $output_dir/kustomization.yaml
echo "kind: Kustomization" >> $output_dir/kustomization.yaml
echo "resources:" >> $output_dir/kustomization.yaml
for file in $output_dir/alertmanager-*.yaml; do
  echo "[INFO] add $file to kustomization.yaml"
  if [ -f "$file" ]; then
    echo "  - $(basename "$file")" >> $output_dir/kustomization.yaml
  fi
done

rm -rf build
