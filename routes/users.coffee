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
  username = req.params.username

  User = mongoose.model('User')
  User.findOne username: username, (err, user) ->
    console.log err if err
    unless user
      res.send('404')
    else
      res.render 'users/show',
      title: username
      user: user

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

exports.getSetting = (req, res) ->
  User = mongoose.model('User')
  
  User.findOne username: req.session.user.username, (err, user) ->
    console.log err if err
    if user
      res.render 'users/setting',
        title: 'user setting'
        user: user

exports.setting = (req, res) ->
  params = req.body.user
  fields = ['nickname', 'signature', 'location', 'website','company', 'github', 'twitter', 'douban', 'self_intro']

  for field in fields
    params[field] = sanitize(sanitize(params[field]).trim()).xss()

  User = mongoose.model('User')
  User.findOne username: req.session.user.username, (err, user) ->
    console.log err if err

    for field in fields 
      user[field] = params[field]

    user.save (err) ->
      console.log err if err
      req.flash 'success', ['save setting success']
      res.redirect '/setting'
      
exports.avatar = (req, res) ->
  res.render 'users/avatar',
    title: 'user setting'

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
