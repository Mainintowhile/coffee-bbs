mongoose = require 'mongoose'
mail = require '../mailers/mail'
bcrypt = require "bcrypt"
sanitize = require('validator').sanitize

# GET '/forgot'
exports.new = (req, res) ->
  res.render 'passwords/forgot', success: req.flash('success'), notices: req.flash('notices')

# POST '/forgot'
exports.create = (req, res) ->
  email = sanitize(req.body.email).trim()

  unless email
    return res.render 'passwords/forgot', email: email, notices: ["邮箱不能为空"] 

  User = mongoose.model('User')
  User.findOne email: email, (err, user) ->
    throw err if err
    unless user
      return res.render 'passwords/forgot', email: email, notices: ["用户不存在"]
    bcrypt.genSalt 10, (err, token) ->
      user.reset_password_token = token
      user.reset_password_sent_at = new Date()
      user.save (err) ->
        throw err if err
        # send mail
        mail.resetPasswordMail(user.email, token, user.username, req.headers.host)
        req.flash 'success', ['确认邮件发送成功']
        res.redirect '/forgot'

# GET 'reset'
exports.edit = (req, res) ->
  username = req.query.name
  token = req.query.token

  User = mongoose.model 'User'
  User.findOne username: username, reset_password_token: token, (err, user) ->
    unless user
      req.flash 'notices', ['link errors, can not reset password']
      return res.redirect '/forgot'
    # check time
    now = new Date().getTime()
    reset_send_at = (new Date(user.reset_password_sent_at)).getTime()
    if now - reset_send_at > 1000 * 60 * 60 * 24
      req.flash 'notices', ['link is expired, please repeat']
      return req.redirect '/forgot'

    res.render 'passwords/edit', username: username, token: token

# post "/reset"
exports.update = (req, res) ->
  username = req.body.username
  password = req.body.password
  password_confirm = req.body.password_confirm
  token = req.body.token

  if !password || !password_confirm
    return res.render 'passwords/edit', notices: ['please check your password'], username: username, token: token

  if password_confirm != password
    return res.render 'passwords/edit', username: username, token: token

  User = mongoose.model 'User'
  User.findOne username: username, reset_password_token: token,  (err, user) ->
    throw err if err
    unless user
      req.flash 'notices', ['link errors, can not reset password, please repeat']
      req.redirect '/forgot'
    user.reset_password_token = null
    user.reset_password_sent_at = null
    user.password = password
    user.save (err) ->
      throw err if err
      req.flash 'success', ['you password has reset']
      res.redirect '/login'
