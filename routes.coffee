routes = require "./routes"
users = require "./routes/users"
topics = require "./routes/topics"
sessions = require "./routes/sessions"
passwords = require "./routes/passwords"
nodes = require "./routes/nodes"
replies = require "./routes/replies"
notifications = require "./routes/notifications"
filter = require "./routes/filter"
search = require "./routes/search"

app = module.parent.exports.app


app.all "*", filter.notifications
# app.get "/", routes.index
app.get "/", topics.index

# search  
app.get '/search', search.index

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
app.get  "/setting/avatar/gravatar", filter.requiredLogined, users.gravatar
app.get  "/setting/password", filter.requiredLogined, users.getSettingPass
app.post "/setting/password", filter.requiredLogined, users.settingPass
app.get "/notifications", filter.requiredLogined, notifications.index

# passwords 
app.get  "/forgot", passwords.new
app.post "/forgot", passwords.create
app.get  "/reset",  passwords.edit
app.post "/reset",  passwords.update

# sessions 
app.get  "/login", sessions.new
app.post "/login", sessions.create
app.get  "/logout", filter.requiredLogined, sessions.destroy

# nodes 
app.get "/nodes/:key", nodes.show

# topcis
app.get  "/topics", topics.index
app.get  "/topics/:id", topics.show
app.get  "/nodes/:key/new", filter.requiredLogined, topics.new
app.post "/nodes/:key/topics", filter.requiredLogined, topics.create
app.post "/topics/:id/favorite", filter.requiredLogined, topics.favorite
app.post "/topics/:id/unfavorite", filter.requiredLogined, topics.unfavorite
app.post "/topics/:id/vote", filter.requiredLogined, topics.vote
# app.get  "/topics/:id/edit", filter.requiredLogined, topics.edit
# app.put  "/topics/:id", filter.requiredLogined, topics.update
# app.delete "/topics/:id", filter.requiredLogined, topics.destroy

# replies
app.post "/topics/:topic_id/replies", filter.requiredLogined, replies.create

# 

app.get "*", (req, res) -> res.status(404).send('Not found')
app.post "*", (req, res) -> res.status(404).send('Not found')