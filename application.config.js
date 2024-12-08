const nconf = require('nconf')
nconf.argv().env().file({ file: 'nconf.json' })

// ************************************
let APP_MOLECULER_METRICS_ENABLED = false
let APP_MOLECULER_API_GATEWAY_PORT = 5000
let APP_MOLECULER_METRICS_PORT = 5050
// ************************************
if (nconf.get('APP_MOLECULER_METRICS_ENABLED') && nconf.get('APP_MOLECULER_METRICS_ENABLED') === 'true') { APP_MOLECULER_METRICS_ENABLED = true }
if (nconf.get('APP_MOLECULER_API_GATEWAY_PORT')) { APP_MOLECULER_API_GATEWAY_PORT = parseInt(nconf.get('APP_MOLECULER_API_GATEWAY_PORT')) }
if (nconf.get('APP_MOLECULER_METRICS_PORT')) { APP_MOLECULER_METRICS_PORT = parseInt(nconf.get('APP_MOLECULER_METRICS_PORT')) }
// ************************************

module.exports = {
  moleculer: {
    port: APP_MOLECULER_API_GATEWAY_PORT,
    metrics: {
      enabled: APP_MOLECULER_METRICS_ENABLED,
      port: APP_MOLECULER_METRICS_PORT
    }
  }
}
