const { KubeConfig, Watch } = require('@kubernetes/client-node')

module.exports = {
  name: 'KubernetesWatcher',
  settings: {
    resources: [
      'nomadproviders',
      'nomadnamespaces'
    ] // Kubernetes resources to monitor
  },
  events: {
    // Event triggered by CRD changes
    'k8s.crd.modified': {
      async handler (payload) {
        const { type, object: { metadata: { name }, kind } } = payload
        const service = kind
        const action = type.toLowerCase()
        const params = payload.object.spec
        this.logger.info('crd modified', service, action)
        await this.broker.call(`${service}.${action}`, {
          name,
          params
        })
      }
    }
  },
  actions: {
  },

  methods: {
    initK8sWatcher () {
      const kc = new KubeConfig()
      kc.loadFromDefault() // Load Kubernetes config (e.g., from KUBECONFIG or cluster defaults)
      const watch = new Watch(kc)
      this.settings.resources.forEach((resource) => {
        const path = `/apis/nomad.hashicorp.com/v1/namespaces//${resource}`
        watch
          .watch(
            path,
            {},
            (type, object) => {
              // Emit an internal Moleculer event for each change
              this.broker.emit('k8s.crd.modified', { type, object })
            },
            (err) => {
              if (err) {
                this.logger.error('Error watching CRDs:', err)
              }
            }
          )
          .then((req) => {
            this.logger.info('K8s Watcher started', resource)
            this.unwatch = req.abort.bind(req) // Save abort function to stop watching
          })
      })
    }
  },

  created () {
    this.logger.info('KubernetesWatcher service created.')
  },

  async started () {
    this.logger.info('KubernetesWatcher service started.')
    this.initK8sWatcher()
  },

  async stopped () {
    this.logger.info('KubernetesWatcher service stopped.')
    if (this.unwatch) this.unwatch() // Stop the Kubernetes watcher
  }
}
