###
Module dependencies.
###
express = require "express"

routes = require "./routes"
users = require "./routes/users"
topics = require "./routes/topics"
sessions = require "./routes/sessions"
passwords = require "./routes/passwords"
midderwares = require "./routes/midderwares"

http = require "http"
path = require "path"
flash = require "connect-flash"

app = express()

#get settings 
devSettings = require('./settings')(app.get("env"))

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.cookieParser()
# app.use express.session(cookie: { maxAge: 60000 }, secret: devSettings.cookieSecret)
app.use express.session(secret: devSettings.cookieSecret)
app.use flash()
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()

app.use (req, res, next) ->
  res.locals.user = req.session.user
  next()

# view helpers
helper = require("./routes/helper")
app.locals(helper)

siteSettings = require("./site_settings")(app.get('env'))
app.locals(siteSettings)

app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

mongoose = require('mongoose')
require('./models/user')
require('./models/topic')
require('./models/counter')

mongoose.connect "mongodb://#{devSettings.host}/#{devSettings.db}", (err) ->
  console.log err if err?


app.get "/", routes.index

# users
app.get  "/members", users.index
app.get  "/u/:username", users.show
app.get  "/register", users.new
app.post "/users/create", users.create
app.get  "/active_account", users.activeAccount
app.get  "/setting", midderwares.requiredLogined, users.getSetting
app.post "/setting", midderwares.requiredLogined, users.setting
app.get  "/setting/avatar", midderwares.requiredLogined, users.avatar

app.get  "/forgot", passwords.new
app.post "/forgot", passwords.create
app.get  "/reset",  passwords.edit
app.post "/reset",  passwords.update

# sessions 
app.get  "/login", sessions.new
app.post "/login", sessions.create
app.get  "/logout", sessions.destroy

# topcis
app.get  "/topics", topics.index
app.get  "/topics/new", topics.new
app.get  "/topics/:id", topics.show
app.post "/topics", topics.create
app.get  "/topics/:id/edit", topics.edit
app.put  "/topics/:id", topics.update
app.delete "/topics/:id", topics.destroy

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port #{app.get("port")}"
