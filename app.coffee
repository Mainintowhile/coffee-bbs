###
Module dependencies.
###
express = require "express"

http = require "http"
path = require "path"
flash = require "connect-flash"

app = express()

#get settings 
Settings = require('./settings')(app.get("env"))

# all environments
app.set "port", process.env.PORT or Settings.port
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.cookieParser()
# app.use express.session(cookie: { maxAge: 60000 }, secret: Settings.cookieSecret)
app.use express.session(secret: Settings.cookieSecret)
app.use flash()
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()

app.use (req, res, next) ->
  res.locals.current_user = req.session.user
  next()

# view helpers
helper = require("./helper")
app.locals(helper)
app.locals(Settings)
app.locals.runEnv = app.get('env')

app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

mongoose = require('mongoose')
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

module.exports.app = app
routes = require './routes'

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port #{app.get("port")}"
