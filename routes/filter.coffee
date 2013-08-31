mongoose = require 'mongoose'

exports.requiredLogined = (req, res, next) -> 
  if req.session && req.session.user
    next()
  else
    if req.xhr
      res.json { success: 0, message: "please_signin" }
    else
      req.flash 'notices', ["Please Signin"]
      res.redirect '/login'

exports.notifications = (req, res, next) ->
  if req.session && req.session.user
    Notification = mongoose.model 'Notification'
    Notification.unreadCount req.session.user._id, (err, count) ->
      throw err if err
      res.locals.notification_count = count
      next()
  else 
    next()
