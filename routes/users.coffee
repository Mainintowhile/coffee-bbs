# check = require('validator').check
sanitize = require('validator').sanitize
Validator = require('validator').Validator
mongoose = require 'mongoose'
mail = require '../services/mail'
bcrypt = require 'bcrypt'
async = require 'async'

# GET /members
exports.index = (req, res) ->
  User = mongoose.model 'User'

  async.parallel
    activeUsers: (callback) ->
      User.activeUsers(49, callback)
    newUsers: (callback) ->
      User.newUsers(49, callback)
    (err, results) ->
      throw err if err
      res.render 'users/index', users: results

# GET /u/:username
exports.show = (req, res) ->
  User = mongoose.model 'User'
  Topic = mongoose.model 'Topic'
  Reply = mongoose.model 'Reply'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err 
    return res.status(404).send('Not found') unless user

    async.parallel
      topics: (callback) ->
        Topic.getTopicListWithNode user.id, 10, (err, topics) ->
          return callback err if err 
          callback null, topics
      replies: (callback) ->
        Reply.findReplyByUserWithTopic user.id, 10, (err, replies) ->
          return callback err if err
          callback null, replies
      (err, results) ->
        throw err if err 
        res.render 'users/show', user: user, topics: results.topics, replies: results.replies

# GET '/register'
exports.new = (req, res) ->
  res.render 'users/new'

# POST /users/create
exports.create = (req, res) ->
  user = req.body.user
  notices = validate(user)

  if notices.length == 0
    User = mongoose.model('User')
    User.find $or: [username: user.username, email: user.email], (err, docs) ->
      throw err if err 
      if docs.length == 0
        async.waterfall [
          (next) ->
            bcrypt.genSalt 10, (err, salt) ->
              return next err if err
              user = new User 
                username: user.username
                email: user.email
                password: user.password
                confirmation_token: salt
              next null, user
          (user, next) ->
            user.save (err, user) ->
              throw err if err 
              next null, user
        ],
        (err, user) ->
          throw err if err 
          mail.sendActiveMail(user.email, user.confirmation_token, user.username)
          req.flash 'success', ['register success, a mail has send, Please check your email']
          res.redirect '/login'
      else
        res.render 'users/new', notices: ["username or email has exists"], username: user.username, email: user.email
  else
    res.render 'users/new', notices: notices, username: user.username, email: user.email

exports.activeAccount = (req, res) ->
  token = req.query.token
  name = req.query.name
  User = mongoose.model('User')

  User.findOne username: name, (err, user) ->
    throw err if err

    if !user || user.confirmation_token != token
      req.flash 'notices', ["message wrong, Please repeat"]
      return res.redirect '/forgot'

    if user.active
      req.flash 'success', ["account has active, Please login"]
      return res.redirect '/login'

    user.active = true
    user.confirmed_at = new Date()
    user.save (err) ->
      throw err if err
      req.flash 'success', ["account actived, Please login"]
      res.redirect '/login'

exports.getSetting = (req, res) ->
  User = mongoose.model('User')
  
  User.findOne username: req.session.user.username, (err, user) ->
    throw err if err
    res.render 'users/setting', user: user if user

exports.setting = (req, res) ->
  params = req.body.user
  fields = ['nickname', 'signature', 'location', 'website','company', 'github', 'twitter', 'douban', 'self_intro']
  params[field] = sanitize(sanitize(params[field]).trim()).xss() for field in fields

  User = mongoose.model('User')
  User.findOne username: req.session.user.username, (err, user) ->
    throw err if err
    user[field] = params[field] for field in fields
    user.save (err) ->
      throw err if err
      req.flash 'success', ['save setting success']
      res.redirect '/setting'
      
exports.getSettingPass = (req, res) ->
  res.render 'users/update_pass', success: req.flash('success')

exports.settingPass = (req, res) ->
  oldPass = req.body.password_old
  password = req.body.password
  password_confirm = req.body.password_confirm
  User = mongoose.model('User')

  unless oldPass && password && password_confirm
    return res.render 'users/update_pass', notices: ["Please check your info"]

  # check password_confirm 
  if password != password_confirm
    return res.render 'users/update_pass', notices: ['password and password_confirm not equal']

  # get user  and check old password
  User.findById req.session.user._id, (err, user) ->
    throw err if err
    user.comparePassword oldPass, (err, isMath) ->
      throw err if err
      if isMath
        user.password = password
        user.save (err, doc) ->
          req.flash 'success', ['update password success']
          res.redirect '/setting/password'
      else
        res.render 'users/update_pass', notices: ['old password not match']

exports.topics = (req, res) ->
  Topic = mongoose.model 'Topic'
  User = mongoose.model 'User'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err 
    return res.status(404).send('Not found') unless user
    Topic.getTopicListWithNode user.id, 100, (err, topics) ->
      throw err if err 
      res.render 'users/topics_list', topics: topics, user: user

exports.replies = (req, res) ->
  Reply = mongoose.model 'Reply'
  User = mongoose.model 'User'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err 
    return res.status(404).send('Not found') unless user
    Reply.findReplyByUserWithTopic user.id, 100, (err, replies) ->
      throw err if err
      res.render 'users/replies_list', replies: replies,  user: user

# GET /u/:username/favorites
exports.favorites = (req, res) ->
  User = mongoose.model 'User'
  Topic = mongoose.model 'Topic'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err
    return res.status(404).send('Not found') unless user
    options = { sort: { created_at: -1 } }
    Topic.getTopicListWithNodeUser { _id: $in: user.favorite_topics }, options, (err, topics) ->
      throw err if err
      res.render 'users/favorites_list', user: user, topics: topics

# GET /setting/avatar
exports.avatar = (req, res) ->
  User = mongoose.model 'User'
  User.findById req.session.user._id, (err, user) ->
    throw err if err 
    res.render 'users/avatar', user: user

# GET /setting/avatar/gravatar
exports.gravatar = (req, res) ->
  User = mongoose.model 'User'
  User.findById req.session.user._id, (err, user) ->
    throw err if err 
    user.gravatar_type = 1
    user.save()
    res.redirect '/setting/avatar'

exports.notifications = (req, res) ->
  res.render 'users/notifications'

# register validate 
validate = (user) ->
  v = new Validator()
  errors = []

  v.error = (msg) ->
    errors.push msg

  v.check(user.username, 'Please enter your name').len(3, 20)
  v.check(user.username, 'Please check your username format').isAlphanumeric()
  v.check(user.email, 'Please enter a valid email address').isEmail()
  v.check(user.password, 'Please check your password').len(4, 20)
  v.check(user.password_confirm, 'Please check your password_confirm').len(4, 20)

  if user.password != user.password_confirm
    errors.push "password do not match"
  return errors
