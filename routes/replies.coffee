mongoose = require 'mongoose'
sanitize = require('validator').sanitize

exports.create = (req, res) ->
  topic_id = req.params.topic_id
  user = req.session.user
  content = sanitize(req.body.content).xss()
  console.log "content is: #{content}"

  Topic = mongoose.model 'Topic'
  Reply = mongoose.model 'Reply'

  unless content
    res.render 'topics/show', 
      Reply_notice: "Reply content not allow blank"

  Topic.findById topic_id, (err, topic) ->
    return throw err if err 
    console.log "content is: #{content}"
    reply = new Reply {user_id: user._id, topic_id: topic.id, content: content, username: user.username }
    console.log "reply is: #{reply}"
    reply.save (err, doc) ->
      return throw err if err 
      topic.replies_count++
      topic.last_replied_by = user.username
      topic.last_replied_at = new Date() 

      topic.save (err, topic) ->
        res.redirect "/topics/#{topic._id}#reply#{topic.replies_count}"
