mongoose = require 'mongoose'
async = require 'async'

# GET /notifications
exports.index = (req, res) ->
  user_id = req.session.user._id
  Notification = mongoose.model 'Notification'
  options =
    limit: 30
    sort: created_at: -1

  Notification.getByUser { user_id: user_id }, options, (err, notifications) ->
    # mark all read
    Notification.update {user_id: user_id}, {status: true}, {multi: true}, (err, numberAffected, raw) ->
      console.log "update #{numberAffected} docs"

    res.render 'users/notifications', notifications: notifications
