mongoose = require 'mongoose'
sanitize = require('validator').sanitize
async = require 'async'

# POST /topics/:id/replies
exports.create = (req, res, next) ->
  topic_id = req.params.topic_id
  user = req.session.user

  Topic = mongoose.model 'Topic'
  Reply = mongoose.model 'Reply'
  User = mongoose.model 'User'

  unless req.body.content
    req.flash 'notices', ["Reply content not allow blank"]
    return res.redirect "topics/#{topic_id}"

  content = sanitize(req.body.content).xss()

  Topic.findById topic_id, (err, topic) ->
    throw err if err 
    return next() unless topic

    reply = new Reply user_id: user._id, topic_id: topic.id, content: content, username: user.username
    reply.save (err, doc) ->
      throw err if err 
      async.parallel [
        (callback) ->
          User.findById user._id, (err, user) ->
            return callback err if err 
            user.reply_count++
            user.save (err, user) ->
              return callback err if err 
              callback null, user
        (callback) ->
          topic.replies_count++
          topic.last_replied_by = user.username
          topic.last_replied_at = new Date() 
          topic.save (err, topic) ->
            return callback err if err
            callback null, topic
      ],
      (err, results) ->
        throw err if err 
        res.redirect "/topics/#{topic._id}#reply#{topic.replies_count}"
