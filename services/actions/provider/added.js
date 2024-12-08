const k8s = require('@kubernetes/client-node')
const kc = new k8s.KubeConfig()
kc.loadFromDefault()
const k8sApi = kc.makeApiClient(k8s.CoreV1Api)

const handler = async function (ctx) {
  try {
    this.logger.info(ctx.action.name, ctx.params)
    const { name, params } = ctx.params
    const body = {
      apiVersion: 'v1',
      kind: 'Secret',
      metadata: {
        name: `provider-${name}`
      },
      type: 'Opaque',
      data: {}
    }
    Object.keys(params).map(key => {
      body.data[key] = Buffer.from(params[key].toString()).toString('base64')
      return true
    })
    try {
      await k8sApi.replaceNamespacedSecret(`provider-${name}`, 'nomad-system', body)
    } catch (err) {
      if (err.response && err.response.statusCode === 404) {
        await k8sApi.createNamespacedSecret('nomad-system', body)
      }
    }
    return {
      success: true
    }
  } catch (e) {
    /* istanbul ignore next */
    this.logger.error(ctx.action.name, e.message)
    /* istanbul ignore next */
    return { success: false, error: e.message }
  }
}

module.exports = {
  handler
}
