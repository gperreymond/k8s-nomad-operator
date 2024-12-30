#!/bin/bash

set -euo pipefail

# Configuration
BUILD_DIR="build"
CHARTS_DIR="charts/remote-charts"
JSONNET_FILE="kube-prometheus.jsonnet"

# Preliminary checks
command -v jsonnet >/dev/null || { echo "[ERROR] jsonnet is required but not found."; exit 1; }
command -v ~/go/bin/gojsontoyaml >/dev/null || { echo "[ERROR] gojsontoyaml is required but not found."; exit 1; }

# Logging with timestamps
log() {
  local level="$1"
  local message="$2"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message"
}

# Directory preparation
log "INFO" "Cleaning up directories..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/manifests/setup"

# Generate manifests
log "INFO" "Generating manifests using jsonnet..."
jsonnet -J vendor -m "$BUILD_DIR/manifests" "$JSONNET_FILE" \
  | xargs -I{} sh -c 'cat {} | ~/go/bin/gojsontoyaml > {}.yaml' -- {}
find "$BUILD_DIR/manifests" -type f ! -name '*.yaml' -delete

log "DEBUG" "Generated files in $BUILD_DIR/manifests:"
ls -l "$BUILD_DIR/manifests"

# Function to process manifests
process_manifests() {
  local prefix="$1"
  local output_dir="$CHARTS_DIR/$prefix/manifests"

  log "INFO" "Processing manifests for prefix: $prefix..."
  rm -rf "$output_dir"
  mkdir -p "$output_dir"

  local matched_files=()
  while IFS= read -r -d '' file; do
    matched_files+=("$file")
  done < <(find "$BUILD_DIR/manifests" -type f -name "${prefix}-*.yaml" -print0)

  if [ ${#matched_files[@]} -eq 0 ]; then
    log "WARNING" "No files found matching prefix ${prefix}-*.yaml."
    return
  fi

  for file in "${matched_files[@]}"; do
    log "INFO" "Moving $(basename "$file") to $output_dir"
    mv "$file" "$output_dir"
  done

  local kustomization_file="$output_dir/kustomization.yaml"
  log "INFO" "Creating $kustomization_file"
  {
    echo "apiVersion: kustomize.config.k8s.io/v1beta1"
    echo "kind: Kustomization"
    echo "resources:"
    for file in "$output_dir"/*.yaml; do
      if [ "$(basename "$file")" != "kustomization.yaml" ]; then
        echo "  - $(basename "$file")"
      fi
    done
  } > "$kustomization_file"
}

# Process specific prefixes
process_manifests "prometheus-operator"
process_manifests "alertmanager"
process_manifests "kube-state-metrics"
process_manifests "prometheus"

# Final cleanup
rm -rf "$BUILD_DIR"
log "INFO" "All manifests have been processed successfully."
