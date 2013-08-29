app = module.parent.exports.app

mongoose = require('mongoose')
Settings = require('./settings')(app.get("env"))

require('./models/user')
require('./models/topic')
require('./models/plane')
require('./models/node')
require('./models/counter')
require('./models/reply')
require('./models/site')

mongoose.connect "mongodb://#{Settings.host}/#{Settings.db}", (err) ->
  process.exit(1) if err

if "development" is app.get('env')
  mongoose.set('debug', true)