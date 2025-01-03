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
    "dnssrv+_grpc._tcp.prometheus-k8s-thanos-sidecar.monitoring-system.svc.cluster.local:10901",
    s.storeEndpoint
  ]
});

local qf = t.queryFrontend(commonConfig.config {
  replicas: 1,
  downstreamURL: 'http://%s.%s.svc.cluster.local.:%d' % [
    q.service.metadata.name,
    q.service.metadata.namespace,
    q.service.spec.ports[1].port,
  ],
  splitInterval: '12h',
  maxRetries: 10,
  logQueriesLongerThan: '10s',
  serviceMonitor: true,
  queryRangeCache: {
    type: 'memcached',
    config+: {
      addresses: ['dnssrv+_client._tcp.thanos-memcached.%s.svc.cluster.local' % commonConfig.config.namespace],
    },
  },
  labelsCache: {
    type: 'memcached',
    config+: {
      addresses: ['dnssrv+_client._tcp.thanos-memcached.%s.svc.cluster.local' % commonConfig.config.namespace],
    },
  },
});

{ ['thanos-compact-' + name]: c[name] for name in std.objectFields(c) } +
{ ['thanos-store-' + name]: s[name] for name in std.objectFields(s) } +
{ ['thanos-query-' + name]: q[name] for name in std.objectFields(q) } +
{ ['thanos-query-frontend-' + name]: qf[name] for name in std.objectFields(qf) if qf[name] != null }
