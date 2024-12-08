const { KubeConfig, Watch } = require('@kubernetes/client-node')

module.exports = {
  name: 'k8s-watcher',
  settings: {
    // https://registry.terraform.io/providers/hashicorp/nomad/latest/docs
    // provider: {
    //   address: 'http://localhost:4646', // NOMAD_ADDR
    //   region: '', // NOMAD_REGION
    //   http_auth: '', // NOMAD_HTTP_AUTH
    //   skip_verify: false, // NOMAD_SKIP_VERIFY
    //   secret_id: '' // NOMAD_TOKEN
    // },
    resources: [
      'nomadnamespaces'
    ] // Kubernetes resources to monitor
  },
  events: {
    // Event triggered by CRD changes
    'k8s.crd.modified': {
      async handler (payload) {
        this.logger.info('CRD modified:', payload)
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
    this.logger.info('k8s-watcher service created.')
  },

  async started () {
    this.logger.info('k8s-watcher service started.')
    this.initK8sWatcher()
  },

  async stopped () {
    this.logger.info('k8s-watcher service stopped.')
    if (this.unwatch) this.unwatch() // Stop the Kubernetes watcher
  }
}
