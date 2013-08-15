###
Module dependencies.
###
express = require("express")

routes = require("./routes")
users = require("./routes/users")
topics = require("./routes/topics")
sessions = require("./routes/sessions")

http = require("http")
path = require("path")
flash = require('connect-flash')

app = express()

#get settings 
devSettings = require('./settings')(app.get("env"))

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.cookieParser()
app.use express.session(cookie: { maxAge: 60000 }, secret: devSettings.cookieSecret)
app.use flash()
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()

app.use (req, res, next) ->
  res.locals.user = req.session.user
  next()

helper = require("./routes/helper")
siteSettings = require("./site_settings")
app.locals(helper)
app.locals(siteSettings)

app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

mongoose = require('mongoose')
require('./models/user')
require('./models/topic')

mongoose.connect "mongodb://#{devSettings.host}/#{devSettings.db}", (err) ->
  console.log err if err?


app.get "/", routes.index

# users
app.get  "/users", users.index
app.get  "/u/:username", users.show
app.get  "/register", users.new
app.post "/users/create", users.create
app.get  "/active_account", users.activeAccount
app.get  "/forgot", users.forgot
app.post "/forgot", users.forgotPassword
app.get  "/reset", users.reset
app.post "/reset", users.resetPassword

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
  console.log "NODE_ENV: #{process.env.NODE_ENV}"
  console.log "app_env: #{app.get("env")}"
  console.log "Express server listening on port #{app.get("port")}"
