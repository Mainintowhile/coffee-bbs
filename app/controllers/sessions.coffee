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
    return res.render 'sessions/new', username: username, notices: ["请检查你的用户名密码"]

  User = mongoose.model('User')
  User.findOne {username: username}, (err, user) ->
    throw err if err
    return res.render 'sessions/new', notices: ["用户#{username}不存在"] unless user
    # 未确认邮件
    unless user.active
      return res.render 'sessions/new', notices: ["用户未激活，激活后登录"]

    user.comparePassword password, (err, isMatch) ->
      throw err if err
      if isMatch
        req.session.user = user
        redirectPath = req.query.next || '/'
        res.redirect redirectPath
      else
        res.render 'sessions/new', notices: ["密码错误"]

exports.destroy = (req, res) ->
  # req.flash 'success', ['logout success']
  req.session.user = null
  res.redirect '/'
