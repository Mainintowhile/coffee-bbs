mongoose = require 'mongoose'
sanitize = require('validator').sanitize

exports.create = (req, res) ->
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
    return res.status(404).send('Not found') unless topic

    reply = new Reply user_id: user._id, topic_id: topic.id, content: content, username: user.username
    #TODO async
    reply.save (err, doc) ->
      throw err if err 
      # update user reply count
      User.findById user._id, (err, current_user) ->
        current_user.reply_count++
        current_user.save()
        
      topic.replies_count++
      topic.last_replied_by = user.username
      topic.last_replied_at = new Date() 

      topic.save (err, topic) ->
        res.redirect "/topics/#{topic._id}#reply#{topic.replies_count}"
