settings = require './settings'

module.exports = (env) ->
  # appfog
  if process.env.VCAP_SERVICES
    env = JSON.parse(process.env.VCAP_SERVICES)
    redis = env['redis-2.2'][0]['credentials']
  else
    settings(env).redis
  


