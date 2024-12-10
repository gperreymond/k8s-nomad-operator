const handler = async function (ctx) {
  try {
    this.logger.info(ctx.action.name, ctx.params)
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
