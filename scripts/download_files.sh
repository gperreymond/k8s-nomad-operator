#!/bin/bash

# ------------------------------------------
# Prometheus Operator
# ------------------------------------------

destination_dir=".tmp/files/prometheus-operator"
rm -rf "$destination_dir"
mkdir -p "$destination_dir"

final_dir="charts/remote-charts/prometheus-operator/manifests"
rm -rf "$final_dir"
mkdir -p "$final_dir"

urls=(
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0alertmanagerCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0podmonitorCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0probeCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0prometheusCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0prometheusagentCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0prometheusruleCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0scrapeconfigCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0servicemonitorCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0thanosrulerCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/setup/0alertmanagerConfigCustomResourceDefinition.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheusOperator-service.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheusOperator-serviceAccount.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheusOperator-clusterRole.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheusOperator-clusterRoleBinding.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheusOperator-networkPolicy.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheusOperator-deployment.yaml"
)

echo "[INFO] prometheus-operator"
for url in "${urls[@]}"; do
  filename=$(basename "$url")
  curl -so "$destination_dir/$filename" "$url"
  if [ $? -eq 0 ]; then
    echo "[INFO]... successfully downloaded $filename"
  else
    echo "[ERROR]... failed to download $filename"
    exit 1
  fi
  echo
done
echo "[INFO] All files have been downloaded."
mv $destination_dir/*.* "$final_dir"
echo "[INFO] All files have been moved."

# ------------------------------------------
# Prometheus Operator
# ------------------------------------------

destination_dir=".tmp/files/prometheus"
rm -rf "$destination_dir"
mkdir -p "$destination_dir"

final_dir="charts/remote-charts/prometheus/manifests"
rm -rf "$final_dir"
mkdir -p "$final_dir"

urls=(
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-clusterRole.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-clusterRoleBinding.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-networkPolicy.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-podDisruptionBudget.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-prometheusRule.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-roleBindingConfig.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-roleBindingSpecificNamespaces.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-roleConfig.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-roleSpecificNamespaces.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-service.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-prometheus.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-serviceAccount.yaml"
  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/tags/v0.14.0/manifests/prometheus-serviceMonitor.yaml"
)

echo ""
echo "[INFO] prometheus"
for url in "${urls[@]}"; do
  filename=$(basename "$url")
  curl -so "$destination_dir/$filename" "$url"
  if [ $? -eq 0 ]; then
    echo "[INFO]... successfully downloaded"
  else
    echo "[ERROR]... failed to download $filename"
    exit 1
  fi
  echo
done
echo "[INFO] All files have been downloaded."
mv $destination_dir/*.* "$final_dir"
echo "[INFO] All files have been moved."
