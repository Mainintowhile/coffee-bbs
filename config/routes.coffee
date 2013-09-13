routes = require "../app/controllers"
users = require "../app/controllers/users"
topics = require "../app/controllers/topics"
sessions = require "../app/controllers/sessions"
passwords = require "../app/controllers/passwords"
nodes = require "../app/controllers/nodes"
replies = require "../app/controllers/replies"
notifications = require "../app/controllers/notifications"
filter = require "../app/controllers/filter"
search = require "../app/controllers/search"

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
app.get  "/register", filter.csrf, users.new
app.post "/users/create", filter.csrf, users.create

app.get  "/active_account", users.activeAccount
app.get  "/resend_active_mail", filter.csrf, users.activeMail
app.post "/resend_active_mail", filter.csrf, users.sendActiveMail

app.get  "/setting", filter.requiredLogined, filter.csrf, users.getSetting
app.post "/setting", filter.requiredLogined, filter.csrf, users.setting
app.get  "/setting/avatar", filter.requiredLogined, users.avatar
# app.post "/setting/avatar", users.uploadAvatar
app.get  "/setting/avatar/gravatar", filter.requiredLogined, users.gravatar
app.get  "/setting/password", filter.requiredLogined, filter.csrf, users.getSettingPass
app.post "/setting/password", filter.requiredLogined, filter.csrf, users.settingPass
app.get  "/notifications", filter.requiredLogined, notifications.index

# passwords 
app.get  "/forgot", filter.csrf, passwords.new
app.post "/forgot", filter.csrf, passwords.create
app.get  "/reset",  filter.csrf, passwords.edit
app.post "/reset",  filter.csrf,  passwords.update

# sessions 
app.get  "/login", filter.csrf, sessions.new
app.post "/login", filter.csrf, sessions.create
app.get  "/logout", filter.requiredLogined, sessions.destroy

# nodes 
app.get  "/nodes/:key", nodes.show

# topcis
app.get  "/topics", topics.index
app.get  "/topics/:id", filter.csrf, topics.show
app.get  "/nodes/:key/new", filter.requiredLogined, filter.csrf, topics.new
app.post "/nodes/:key/topics", filter.requiredLogined, filter.csrf, topics.create
app.post "/topics/:id/favorite", filter.requiredLogined, topics.favorite 
app.post "/topics/:id/unfavorite", filter.requiredLogined, topics.unfavorite 
app.post "/topics/:id/vote", filter.requiredLogined, topics.vote 
# app.get  "/topics/:id/edit", filter.requiredLogined, topics.edit
# app.put  "/topics/:id", filter.requiredLogined, topics.update
# app.delete "/topics/:id", filter.requiredLogined, topics.destroy

# replies
app.post "/topics/:topic_id/replies", filter.requiredLogined, filter.csrf, replies.create

# 

app.get "*", (req, res) -> res.status(404).send('Not found')
app.post "*", (req, res) -> res.status(404).send('Not found')
