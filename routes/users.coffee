# check = require('validator').check
sanitize = require('validator').sanitize
Validator = require('validator').Validator
mongoose = require 'mongoose'
mail = require '../services/mail'
bcrypt = require "bcrypt"
#crypto = require 'crypto'

exports.index = (req, res) ->
  res.send "respond with a resource"

exports.show = (req, res) ->
  res.render 'users/show',
    title: req.params.username

# Get 'register'
exports.new = (req, res) ->
  res.render 'users/new', 
    title: "register"

exports.create = (req, res) ->
  user = req.body.user
  notices = validate(user)

  if notices.length == 0
    User = mongoose.model('User')
    User.find $or: [username: user.username, email: user.email], (err, docs) ->
      if docs.length == 0
        user = new User {
          username: user.username, 
          email: user.email, 
          password: user.password
        }
        token = bcrypt.genSaltSync(10)
        user.confirmation_token = token
        user.save (err, user, numberAffected) ->
          console.log err if err
          mail.sendActiveMail(user.email, token, user.username)
          req.flash 'success', 'register success, a mail has send, Please check your email'
          res.redirect '/login'
      else
        res.render 'users/new',
          notices: ["username or email has exists"]
          username: user.username
          email: user.email
  else
    res.render 'users/new',
      notices: notices
      username: user.username
      email: user.email

exports.activeAccount = (req, res) ->
  token = req.query.token
  name = req.query.name 
  User = mongoose.model('User')

  User.findOne username: name, (err, user) ->
    console.log err if err 

    if !user || user.confirmation_token != token
      req.flash 'notices', "message wrong, Please repeat" 
      return res.redirect '/forgot'

    if user.active
      req.flash 'success', "account has active, Please login"
      return res.redirect '/login'

    user.active = true
    user.confirmed_at = new Date()
    user.save (err) ->
      console.log err if err 
      req.flash 'success', "account actived, Please login"
      res.redirect '/login'


# get '/forgot' 
exports.forgot = (req, res) ->
  res.render 'users/forgot',
    title: "reset password"
    success: req.flash 'success'
    notices: req.flash 'notices'

# post '/forgot' 
# params: username, email
exports.forgotPassword = (req, res) ->
  username = sanitize(req.body.username).trim()
  email = sanitize(req.body.email).trim().toLowerCase()
  notices = []
  notices.push "username can not blank" unless username
  notices.push "email can not blank" unless email

  if notices.length > 0
     return res.render 'users/forgot',
       title: "reset password"
       username: username
       email: email
       notices: notices

  User = mongoose.model('User')
  User.findOne email: email, username: username, (err, user) ->
    unless user
      return res.render 'users/forgot',
        title: "reset password"
        username: username
        email: email
        notices: ["the user not exists"]
    # save reset token and reset time 
    token = bcrypt.genSaltSync(10)
    user.reset_password_token = token
    user.reset_password_sent_at = new Date()
    user.save (err) ->
      console.log err if err
      # send mail
      mail.resetPasswordMail(user.email, token, user.username)
      req.flash('success', 'a mail send for you, Please check')
      res.redirect '/forgot'

# get '/reset'
exports.reset = (req, res) ->
  username = req.query.name
  token = req.query.token
  #return res.send "username: #{username}, token: #{token}"

  User = mongoose.model 'User'
  User.findOne username: username, reset_password_token: token, (err, user) ->
    unless user
      req.flash 'notices', 'link errors, can not reset password'
      return res.redirect '/forgot'
    # check time
    now = new Date().getTime()
    reset_send_at = (new Date(user.reset_password_sent_at)).getTime()
    if now - reset_send_at > 1000 * 60 * 60 * 24
      req.flash 'notices', 'link is expired, please repeat'
      return req.redirect '/forgot'

    res.render 'users/reset',
      title: 'reset password'
      username: username
      token: token
    

# post '/reset'
# params: username, password, password_confirm, token
exports.resetPassword = (req, res) ->
  username = req.body.username
  password = req.body.password
  password_confirm = req.body.password_confirm
  token = req.body.token

  if !password || !password_confirm 
    return res.render 'users/reset', 
      title : 'reset password'
      notices: ['please check your password']
      username: username
      token: token

  if password_confirm != password
    return res.render 'users/reset', 
      title : 'reset password'
      username: username
      token: token

  User = mongoose.model 'User'
  User.findOne username: username, reset_password_token: token,  (err, user) ->
    console.log err if err 
    unless user
      req.flash 'notices', ['link errors, can not reset password, please repeat']
      req.redirect '/forgot'
    user.reset_password_token = null 
    user.reset_password_sent_at = null
    user.password = password
    user.save (err) ->
      console.log err if err
      req.flash 'success', 'you password has reset'
      res.redirect '/login'

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

#md5 = (str) ->
#  md5sum = crypto.createHash 'md5'
#  md5sum.update str
#  str = md5sum.digest 'hex'
#  return str
