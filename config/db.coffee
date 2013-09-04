app = module.parent.exports.app

mongoose = require 'mongoose'
settings = require('./settings')(app.get("env"))

require '../app/models/user'
require '../app/models/topic'
require '../app/models/plane'
require '../app/models/node'
require '../app/models/counter'
require '../app/models/reply'
require '../app/models/site'
require '../app/models/notification'

# support appfog service
if process.env.VCAP_SERVICES
  env = JSON.parse(process.env.VCAP_SERVICES)
  mongo = env['mongodb-1.8'][0]['credentials']
  mongoose.connect "mongodb://#{mongo.username}:#{mongo.password}@#{mongo.hostname}:#{mongo.port}/#{mongo.db}", (err) ->
    console.log err
    process.exit(1) if err
else
  mongoose.connect "mongodb://#{settings.mongo.host}/#{settings.mongo.db}", (err) ->
    console.log err
    process.exit(1) if err

if "development" is app.get('env')
  mongoose.set('debug', true)
