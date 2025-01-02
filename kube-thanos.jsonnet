local t = import 'kube-thanos/thanos.libsonnet';

local commonConfig = {
  config+:: {
    local cfg = self,
    namespace: 'thanos-system',
    version: 'v0.37.2',
    image: 'quay.io/thanos/thanos:' + cfg.version,
    imagePullPolicy: 'IfNotPresent',
    replicaLabels: ['prometheus_replica', 'rule_replica'],
    objectStorageConfig: {
      name: 'thanos-objstore-config',
      key: 'thanos.yaml',
    },
    volumeClaimTemplate: {
      spec: {
        accessModes: ['ReadWriteOnce'],
        resources: {
          requests: {
            storage: '10Gi',
          },
        },
      },
    },
  },
};

local sc = t.sidecar(commonConfig {
  namespace: 'monitoring-system',
  serviceMonitor: true,
  serviceLabelSelector: {
    "app.kubernetes.io/part-of": "kube-prometheus",
    "app.kubernetes.io/component": "thanos-sidecar"
  }
});

local c = t.compact(commonConfig.config {
  replicas: 1,
  serviceMonitor: true,
  resources: {
    requests: { cpu: 0.123, memory: '123Mi' },
    limits: { cpu: 0.420, memory: '420Mi' },
  },
  disableDownsampling: true,
  deleteDelay: 0,
  deduplicationReplicaLabels: super.replicaLabels  // reuse same labels for deduplication
});

local s = t.store(commonConfig.config {
  replicas: 1,
  serviceMonitor: true,
});

local q = t.query(commonConfig.config {
  replicas: 1,
  replicaLabels: ['prometheus_replica', 'rule_replica'],
  serviceMonitor: true,
  queryAutoDownsampling: true,
  queryTimeout: "5m",
  lookbackDelta: "15m",
  stores: [
    'dnssrv+_grpc._tcp.%s.%s.svc.cluster.local' % [service.metadata.name, service.metadata.namespace]
    for service in [sc.service, s.service]
  ]
});

{ ['thanos-compact-' + name]: c[name] for name in std.objectFields(c) } +
{ ['thanos-store-' + name]: s[name] for name in std.objectFields(s) } +
{ ['thanos-query-' + name]: q[name] for name in std.objectFields(q) }

