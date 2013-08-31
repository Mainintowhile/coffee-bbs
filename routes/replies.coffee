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
  # Notification = mongoose.model 'Notification'

  unless req.body.content
    # req.flash 'notices', ["Reply content not allow blank"]
    req.flash 'notices', ["回复不允许为空"]
    return res.redirect "topics/#{topic_id}"

  content = sanitize(req.body.content).xss()

  Topic.findById topic_id, (err, topic) ->
    throw err if err 
    return next() unless topic

    reply = new Reply user_id: user._id, topic_id: topic.id, content: content, username: user.username
    reply.save (err, reply) ->
      throw err if err 
      async.parallel [
        # 用户回复数加1 
        (callback) ->
          User.findById user._id, (err, user) ->
            return callback err if err 
            user.reply_count++
            user.save (err, user) ->
              return callback err if err 
              callback null, user
        # 主题回复数加1 
        (callback) ->
          topic.replies_count++
          topic.last_replied_by = user.username
          topic.last_replied_at = new Date() 
          topic.save (err, topic) ->
            return callback err if err
            callback null, topic
        #创建提醒
        (callback) ->
          # 排除topic作者自己回复
          return callback null, null if topic.user_id.toString() == user._id

          reply.sendReplyNotification topic.user_id, (err, notifiation) ->
            return callback err if err 
            callback null, notifiation
        # 提到的发送提醒
        (callback) ->
          reply.getMentionUserIds (err, ids) ->
            return callback err if err 
            return callback null, null if ids.length == 0
            reply.sendReplyMentionNotification ids, (err) ->
              return callback err if err 
              callback null, null
      ],
      (err, results) ->
        throw err if err 
        res.redirect "/topics/#{topic._id}#reply#{topic.replies_count}"
