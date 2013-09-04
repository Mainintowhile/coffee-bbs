mongoose = require 'mongoose'
mail = require '../mailers/mail'
bcrypt = require "bcrypt"
sanitize = require('validator').sanitize

# GET '/forgot'
exports.new = (req, res) ->
  res.render 'passwords/new', success: req.flash('success'), notices: req.flash('notices')

# POST '/forgot'
exports.create = (req, res) ->
  username = sanitize(req.body.username).trim()
  email = sanitize(req.body.email).trim()
  notices = []
  notices.push "username can not blank" unless username
  notices.push "email can not blank" unless email

  if notices.length > 0
     return res.render 'passwords/new', username: username, email: email, notices: notices

  User = mongoose.model('User')
  User.findOne email: email, username: username, (err, user) ->
    throw err if err
    unless user
      return res.render 'passwords/new', username: username, email: email, notices: ["the user not exists"]
    # save reset token and reset time 
    token = bcrypt.genSaltSync(10)
    user.reset_password_token = token
    user.reset_password_sent_at = new Date()
    user.save (err) ->
      throw err if err
      # send mail
      mail.resetPasswordMail(user.email, token, user.username)
      req.flash 'success', ['a mail send for you, Please check']
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
