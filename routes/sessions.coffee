# check = require('validator').check
sanitize = require('validator').sanitize
# Validator = require('validator').Validator
mongoose = require 'mongoose'

exports.new = (req, res) ->
  res.render 'sessions/new', 
    title: "login"
    success: req.flash 'success'

exports.create = (req, res) ->
  email = sanitize(req.body.email).trim().toLowerCase()
  password = sanitize(req.body.password).trim()

  if !email || !password
    return res.render 'sessions/new',
      title: "login"
      email: email
      notice: "Please check Your email or password"

  User = mongoose.model('User')
  User.findOne {email: email}, (err, user) ->
    console.log err if err
    # user don't exist
    unless user
      return res.render 'sessions/new',
        title: "login"
        notice: "user #{email} do not exist"
    unless user.active
      return res.render 'sessions/new',
      #TODO send mail
        title: "login"
        notice: "the account did't active"

    user.comparePassword password, (err, isMatch) ->
      console.log err if err
      if isMatch
        # req.flash 'success', 'login success'
        req.session.user = user
        console.log "sessions is：#{req.session.user}"
        res.redirect '/'
      else
        res.render 'sessions/new',
          title: "login"
          notice: "password do not match"


exports.destroy = (req, res) ->
  req.session.destroy()
  # req.flash('success', 'logout success')
  res.redirect '/'
