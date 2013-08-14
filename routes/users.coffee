# check = require('validator').check
sanitize = require('validator').sanitize
Validator = require('validator').Validator
mongoose = require 'mongoose'
mail = require '../services/mail'
crypto = require 'crypto'

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
        user.save (err, user, numberAffected) ->
          console.log err if err
          mail.sendActiveMail(user.email, md5(user.email), user.username)
          res.redirect '/'
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

exports.active_account = (req, res) ->
  token = req.query.token
  name = req.query.name 
  User = mongoose.model('User')

  User.findOne username: name, (err, user) ->
    console.log err if err 
    if !user || md5(user.email) != token
      req.flash 'notices', "message wrong, Please repeat" 
      return res.redirect '/forgot'

    if user.active
      req.flash 'success', "account has active"
      return res.redirect '/'

    user.active = true
    # user.confirmed_at = Date.now
    user.save (err) ->
      console.log err if err 
      req.flash 'success', "account actived, Please login"
      res.redirect '/login'



exports.forgot = (req, res) ->
  res.render 'users/forgot',
    title: "reset password"
    success: req.flash 'success'
    notices: req.flash 'notices'

exports.resetPassword = (req, res) ->
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

  # send mail
  req.flash('success', 'a mail send for you, Please check')
  res.redirect '/forgot'

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

md5 = (str) ->
  md5sum = crypto.createHash 'md5'
  md5sum.update str
  str = md5sum.digest 'hex'
  return str
