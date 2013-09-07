###
Module dependencies.
###
express = require "express"

http = require "http"
path = require "path"
flash = require "connect-flash"

app = express()
module.exports.app = app
#get settings 
Settings = require('./config/settings')(app.get('env'))
RedisStore = require('connect-redis')(express)

# all environments
app.set "port", process.env.PORT or Settings.port
app.set "views", __dirname + "/app/views"
app.set "view engine", "jade"
app.use express.cookieParser()
# app.use express.session(cookie: { maxAge: 60000 }, secret: Settings.cookieSecret)
redisOptions = require('./config/redis')(app.get('env'))
app.use express.session(
  store: new RedisStore redisOptions
  secret: Settings.cookieSecret
  cookie: { maxAge: 60 * 60 * 1000}
)
app.use flash()
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()

# current user
app.use (req, res, next) ->
  res.locals.current_user = req.session.user
  next()

# view helpers
helper = require("./lib/helper")
app.locals(helper)
app.locals(Settings)
app.locals.runEnv = app.get('env')

# routes
app.use express.static(path.join(__dirname, "public"))
app.use app.router

# error handle
app.use (err, req, res, next) ->
  if err
    #TODO loger
    console.error(err)
    res.send(500, 'Something broke!')
  else
    next()

routes = require './config/routes'
db = require './config/mongodb'

# development only
app.use express.errorHandler()  if "development" is app.get("env")

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port #{app.get("port")}"
