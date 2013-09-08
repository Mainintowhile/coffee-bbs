sanitize = require('validator').sanitize
mongoose = require 'mongoose'

# GET '/login'
exports.new = (req, res) ->
  return res.redirect '/' if req.session && req.session.user
  res.render 'sessions/new', success: req.flash('success'), notices: req.flash('notices'), next: req.query.next

# POST '/login'
exports.create = (req, res) ->
  username = sanitize(req.body.username).trim().toLowerCase()
  password = sanitize(req.body.password).trim()

  unless username && password
    return res.render 'sessions/new', username: username, notices: ["Please check Your username or password"]

  User = mongoose.model('User')
  User.findOne {username: username}, (err, user) ->
    throw err if err
    return res.render 'sessions/new', notices: ["user #{username} do not exist"] unless user
    # 未确认邮件
    unless user.active
      return res.render 'sessions/new', notices: ["the account did't active"]

    user.comparePassword password, (err, isMatch) ->
      throw err if err
      if isMatch
        req.session.user = user
        redirectPath = req.query.next || '/'
        res.redirect redirectPath
      else
        res.render 'sessions/new', notices: ["password do not match"]

exports.destroy = (req, res) ->
  # req.flash 'success', ['logout success']
  req.session.user = null
  res.redirect '/'
