###
Module dependencies.
###
express = require "express"

routes = require "./routes"
users = require "./routes/users"
topics = require "./routes/topics"
sessions = require "./routes/sessions"
passwords = require "./routes/passwords"
nodes = require "./routes/nodes"
replies = require "./routes/replies"
filter = require "./routes/filter"

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
  res.locals.current_user = req.session.user
  next()

# view helpers
helper = require("./routes/helper")
app.locals(helper)

siteSettings = require("./site_settings")(app.get('env'))
app.locals(siteSettings)
app.locals(devSettings)
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

mongoose.connect "mongodb://#{devSettings.host}/#{devSettings.db}", (err) ->
  process.exit(1) if err

if "development" is app.get('env')
  mongoose.set('debug', true)


# app.get "/", routes.index
app.get "/", topics.index

# users
app.get  "/members", users.index
app.get  "/u/:username", users.show
app.get  "/u/:username/topics", users.topics
app.get  "/u/:username/replies", users.replies
app.get  "/u/:username/favorites", users.favorites
app.get  "/register", users.new
app.post "/users/create", users.create
app.get  "/active_account", users.activeAccount
app.get  "/setting", filter.requiredLogined, users.getSetting
app.post "/setting", filter.requiredLogined, users.setting
app.get  "/setting/avatar", filter.requiredLogined, users.avatar
app.get  "/setting/password", filter.requiredLogined, users.getSettingPass
app.post "/setting/password", filter.requiredLogined, users.settingPass


app.get  "/forgot", passwords.new
app.post "/forgot", passwords.create
app.get  "/reset",  passwords.edit
app.post "/reset",  passwords.update

# sessions 
app.get  "/login", sessions.new
app.post "/login", sessions.create
app.get  "/logout", sessions.destroy

# nodes 
app.get "/nodes/:key", nodes.show

# topcis
app.get  "/topics", topics.index
app.get  "/topics/:id", topics.show
app.get  "/nodes/:key/new", filter.requiredLogined, topics.new
app.post "/nodes/:key/topics", filter.requiredLogined, topics.create
app.post "/topics/:id/favorite", filter.requiredLogined, topics.favorite
app.post "/topics/:id/unfavorite", filter.requiredLogined, topics.unfavorite
# app.get  "/topics/:id/edit", filter.requiredLogined, topics.edit
# app.put  "/topics/:id", filter.requiredLogined, topics.update
# app.delete "/topics/:id", filter.requiredLogined, topics.destroy

# replies

app.post "/topics/:topic_id/replies", filter.requiredLogined, replies.create

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port #{app.get("port")}"
