check = require('validator').check
sanitize = require('validator').sanitize
Validator = require('validator').Validator
qiniu = require '../../lib/qiniu'
settings = require("../../config/settings")(process.env.NODE_ENV or 'development')

mongoose = require 'mongoose'
mail = require '../mailers/mail'
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
exports.show = (req, res, next) ->
  User = mongoose.model 'User'
  Topic = mongoose.model 'Topic'
  Reply = mongoose.model 'Reply'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err
    return next() unless user

    async.parallel
      topics: (callback) ->
        user.recentTopicsList 10, (err, topics) ->
          return callback err if err
          callback null, topics
      replies: (callback) ->
        user.recentRepliesList 10, (err, replies) ->
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

  if notices.length != 0
    res.render 'users/new', notices: notices, username: user.username, email: user.email
  else
    User = mongoose.model('User')
    User.find $or: [{username: user.username}, {email: user.email}], (err, docs) ->
      throw err if err
      if docs.length > 0
        res.render 'users/new', notices: ["username or email has exists"], username: user.username, email: user.email
      else
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
          mail.sendActiveMail(user.email, user.confirmation_token, user.username, req.headers.host)
          req.flash 'success', ['注册成功，确认邮件发到你邮件，请确认你的邮箱']
          res.redirect '/login'

exports.activeAccount = (req, res) ->
  token = req.query.token
  name = req.query.name
  User = mongoose.model('User')

  User.findOne username: name, (err, user) ->
    throw err if err

    if !user || user.confirmation_token != token
      req.flash 'notices', ["信息有错，请重新激活"]
      return res.redirect '/forgot'

    if user.active
      req.flash 'success', ["帐号已经激活，请登录"]
      return res.redirect '/login'

    user.active = true
    user.confirmed_at = new Date()
    user.save (err) ->
      throw err if err
      req.flash 'success', ["激活成功，请登录"]
      res.redirect '/login'

# GET '/resend_active_mail'
exports.activeMail = (req, res) ->
  res.render 'users/resend_active_mail', notices: req.flash('notices')

# POST '/resend_active_mail'
exports.sendActiveMail = (req, res) ->
  email = req.body.email
  try
    check(email).notNull().isEmail()
  catch e
    return res.render 'users/resend_active_mail',email: email, notices: ['请输入正确的邮箱格式']

  User = mongoose.model 'User'
  User.findOne email: email, (err, user) ->
    throw err if err
    unless user
      return res.render 'users/resend_active_mail', notices: ['用户不存在']

    if user.active
      req.flash 'success', ['用户已经激活，请登录']
      return res.redirect '/login'

    bcrypt.genSalt 10, (err, salt) ->
      throw err if err
      user.confirmation_token = salt
      user.save (err, doc) ->
        throw err if err
        mail.sendActiveMail(user.email, salt, user.username, req.headers.host)
        req.flash 'success', ['确认邮件发送成功']
        res.redirect '/login'

# GET /setting
exports.getSetting = (req, res) ->
  User = mongoose.model('User')
  
  User.findOne username: req.session.user.username, (err, user) ->
    throw err if err
    res.render 'users/setting', user: user, success: req.flash('success')

# POST /setting
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
      req.flash 'success', ['保存设置成功']
      res.redirect '/setting'
      
# GET /setting/password
exports.getSettingPass = (req, res) ->
  res.render 'users/update_pass', success: req.flash('success')

# POST /setting/password
exports.settingPass = (req, res) ->
  oldPass = req.body.password_old
  password = req.body.password
  password_confirm = req.body.password_confirm
  User = mongoose.model('User')

  unless oldPass && password && password_confirm
    return res.render 'users/update_pass', notices: ["输入不能为空"]

  # check password_confirm 
  if password != password_confirm
    return res.render 'users/update_pass', notices: ['密码不匹配']

  # get user  and check old password
  User.findById req.session.user._id, (err, user) ->
    throw err if err
    user.comparePassword oldPass, (err, isMath) ->
      throw err if err
      if isMath
        user.password = password
        user.save (err, doc) ->
          req.flash 'success', ['更改密码成功']
          res.redirect '/setting/password'
      else
        res.render 'users/update_pass', notices: ['旧密码不正确']

# GET /u/:username/topics
exports.topics = (req, res, next) ->
  Topic = mongoose.model 'Topic'
  User = mongoose.model 'User'
  currentPage = parseInt(req.query.p, 10) || 1
  pageSize = settings.page_size
  skip = pageSize * (currentPage - 1)

  User.findOne username: req.params.username, (err, user) ->
    throw err if err
    return next() unless user
    Topic.getTopicListWithNode user.id, pageSize, skip, (err, topics) ->
      throw err if err
      res.render 'users/topics_list', topics: topics, user: user

# GET /u/:username/replies
exports.replies = (req, res, next) ->
  Reply = mongoose.model 'Reply'
  User = mongoose.model 'User'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err
    return next() unless user
    Reply.findReplyByUserWithTopic user.id, 100, (err, replies) ->
      throw err if err
      res.render 'users/replies_list', replies: replies,  user: user

# GET /u/:username/favorites
exports.favorites = (req, res, next) ->
  User = mongoose.model 'User'
  Topic = mongoose.model 'Topic'

  User.findOne username: req.params.username, (err, user) ->
    throw err if err
    return next() unless user
    options = { sort: { created_at: -1 } }
    Topic.getTopicListWithNodeUser { _id: $in: user.favorite_topics }, options, (err, topics) ->
      throw err if err
      res.render 'users/favorites_list', user: user, topics: topics

# GET /setting/avatar
exports.avatar = (req, res) ->
  User = mongoose.model 'User'
  User.findById req.session.user._id, (err, user) ->
    throw err if err
    if req.query.upload_ret
      user.gravatar_type = 2
      user.save()
    uptoken = qiniu.upToken(user.reg_id, req.headers.host)
    res.render 'users/avatar', user: user, uploadToken: uptoken, key: user.reg_id

# # POST /setting/avatar
# exports.uploadAvatar = (req, res) ->
#   console.log "form qiniu"
#   console.log "email_md5 is: #{req.body.callbackBody}"
#   res.json { success: 'success' }

# GET /setting/avatar/gravatar
exports.gravatar = (req, res) ->
  User = mongoose.model 'User'
  User.findById req.session.user._id, (err, user) ->
    throw err if err
    user.gravatar_type = 1
    user.save()
    res.redirect '/setting/avatar'

# register validate 
validate = (user) ->
  v = new Validator()
  errors = []

  v.error = (msg) ->
    errors.push msg

  v.check(user.username, '用户名不能为空').len(4, 20)
  v.check(user.username, '用户名格式不正确').isAlphanumeric()
  v.check(user.email, '邮件地址不可用').isEmail()
  v.check(user.password, '密码不能为空').len(4, 20)
  v.check(user.password_confirm, '确认密码不能为空').len(4, 20)

  if user.password != user.password_confirm
    errors.push "两次密码不一致"
  return errors

