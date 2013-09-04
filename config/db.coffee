app = module.parent.exports.app

mongoose = require 'mongoose'
Settings = require('./settings')(app.get("env"))

require '../app/models/user'
require '../app/models/topic'
require '../app/models/plane'
require '../app/models/node'
require '../app/models/counter'
require '../app/models/reply'
require '../app/models/site'
require '../app/models/notification'

mongoose.connect "mongodb://#{Settings.host}/#{Settings.db}", (err) ->
  console.log err
  process.exit(1) if err

if "development" is app.get('env')
  mongoose.set('debug', true)
