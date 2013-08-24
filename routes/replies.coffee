mongoose = require 'mongoose'
sanitize = require('validator').sanitize

exports.create = (req, res) ->
  topic_id = req.params.topic_id
  user = req.session.user
  content = sanitize(req.body.content).xss()

  Topic = mongoose.model 'Topic'
  Reply = mongoose.model 'Reply'
  User = mongoose.model 'User'

  unless content
    res.render 'topics/show', 
      Reply_notice: "Reply content not allow blank"

  Topic.findById topic_id, (err, topic) ->
    return throw err if err 
    reply = new Reply {user_id: user._id, topic_id: topic.id, content: content, username: user.username }
    reply.save (err, doc) ->
      return throw err if err 
      # update user reply count
      User.findById user._id, (err, current_user) ->
        current_user.reply_count++
        current_user.save()
        
      topic.replies_count++
      topic.last_replied_by = user.username
      topic.last_replied_at = new Date() 

      topic.save (err, topic) ->
        res.redirect "/topics/#{topic._id}#reply#{topic.replies_count}"
