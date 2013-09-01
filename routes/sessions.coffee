sanitize = require('validator').sanitize
mongoose = require 'mongoose'

exports.new = (req, res) ->
  return res.redirect '/' if req.session && req.session.user
  res.render 'sessions/new', success: req.flash('success'), notices: req.flash('notices')

exports.create = (req, res) ->
  email = sanitize(req.body.email).trim().toLowerCase()
  password = sanitize(req.body.password).trim()

  unless email && password
    return res.render 'sessions/new', email: email, notices: ["Please check Your email or password"]

  User = mongoose.model('User')
  User.findOne {email: email}, (err, user) ->
    throw err if err 
    return res.render 'sessions/new', notices: ["user #{email} do not exist"] unless user
    #TODO send mail
    unless user.active
      return res.render 'sessions/new', notices: ["the account did't active"] 

    user.comparePassword password, (err, isMatch) ->
      throw err if err 
      if isMatch
        req.session.user = user
        res.redirect '/'
      else
        res.render 'sessions/new', notices: ["password do not match"]

exports.destroy = (req, res) ->
  # req.flash 'success', ['logout success']
  req.session.user = null
  res.redirect '/'
