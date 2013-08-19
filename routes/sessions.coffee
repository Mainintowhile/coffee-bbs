# check = require('validator').check
sanitize = require('validator').sanitize
# Validator = require('validator').Validator
mongoose = require 'mongoose'

exports.new = (req, res) ->
  res.render 'sessions/new',
    title: "login"
    success: req.flash 'success'
    notices: req.flash 'notices'

exports.create = (req, res) ->
  email = sanitize(req.body.email).trim().toLowerCase()
  password = sanitize(req.body.password).trim()

  if !email || !password
    return res.render 'sessions/new',
      title: "login"
      email: email
      notices: ["Please check Your email or password"]

  User = mongoose.model('User')
  User.findOne {email: email}, (err, user) ->
    console.log err if err
    # user don't exist
    unless user
      return res.render 'sessions/new',
        title: "login"
        notices: ["user #{email} do not exist"]
    unless user.active
      return res.render 'sessions/new',
      #TODO send mail
        title: "login"
        notices: ["the account did't active"]

    user.comparePassword password, (err, isMatch) ->
      console.log err if err
      if isMatch
        req.session.user = user
        res.redirect '/'
      else
        res.render 'sessions/new',
          title: "login"
          notices: ["password do not match"]

exports.destroy = (req, res) ->
  #TODO
  req.session.destroy()
  # req.flash 'success', ['logout success']
  res.redirect '/'
