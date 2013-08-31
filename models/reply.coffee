mongoose = require 'mongoose'
async = require 'async'
lib = require './lib'

Schema = mongoose.Schema

replySchema = new Schema(
  user_id: { type: Schema.Types.ObjectId, index: true }
  topic_id: { type: Schema.Types.ObjectId, index: true }
  content:  { type: String, required: true }
  content_html:  { type: String }
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)

# 获得topic的所有回复，并得到每个回复的user
# @params topic_id, callback
replySchema.statics.findRepliesByTopicId = (topic_id, callback) ->
  @find(topic_id: topic_id).sort(created_at: 'asc').exec (err, replies) ->
    return callback err if err
    async.map replies, getUser, (err, results) -> 
      return callback err if err
      callback null, results

# 获得user的所有回复，并得到每个回复的topic信息
# @params user_id, count, callback
# replies list 
replySchema.statics.findReplyByUserWithTopic = (user_id, count, callback) ->
  @find(user_id: user_id).limit(count).sort(created_at: -1).exec (err, replies) ->
    return callback err if err 
    async.map replies, getTopic, (err, results) ->
      return callback err if err
      callback null, results

# Get a reply's user
getUser = (reply, callback) ->
  User = mongoose.model 'User'
  User.findById reply.user_id, (err, user) ->
    return callback err if err 
    reply.user = user
    callback null, reply

# Get which topic by replied 
# append user info to topic 
getTopic = (reply, callback) ->
  Topic = mongoose.model 'Topic'
  User = mongoose.model 'User'

  async.waterfall [
    (next) ->
      Topic.findById reply.topic_id, 'title user_id', (err, topic) ->
        return next err if err
        next null, topic
    (topic, next) ->
      User.findById topic.user_id, 'username', (err, user) ->
        return next err if err
        next null, topic, user
  ],
  (err, topic, user) ->
    return callback err if err
    topic.user = user
    reply.topic = topic
    callback null, reply

# 创建回复，发送提醒
replySchema.methods.sendReplyNotification = (who, callback) ->
  Notification = mongoose.model 'Notification'

  # 回复提醒
  notification = new Notification 
    user_id: who
    notifiable_id: @topic_id
    action: 'reply'
    action_user_id: @user_id
    content: @content_html
    # content: lib.replyToHtml(@content)

  notification.save (err, doc) ->
    return callback err if err 
    callback null, doc

# 获取回复中提到的用户名，返回数组
# replySchema.methods.getMentionUsers =  () -> lib.findMentionUsers(@content)

# 获取用户的id, async map中迭代用
getUserIdByUsername = (username, callback) ->
  User = mongoose.model 'User'
  User.findOne username: username, (err, user) ->
    return callback err if err 
    return callback null, null unless user
    callback null, user.id 

replySchema.methods.getMentionUserIds = (callback) ->
  # 获取回复中提到的用户名，返回数组
  usernames = lib.findMentionUsers(@content)

  async.map usernames, getUserIdByUsername, (err, ids) ->
    return callback err if err
    callback null, ids

# async each 发送提醒
# replySchema.methods.sendNotification = (who, callback) ->
# 将reply实例context绑定
sendNotification = (who, callback) ->
  # user 不存在
  return callback null unless who 
  # 排除自己
  return callback null if who.toString() == @user_id.toString()

  Notification = mongoose.model 'Notification'
  notification = new Notification
    user_id: who
    notifiable_id: @topic_id
    action: 'reply_mention'
    action_user_id: @user_id
    content: @content_html

  notification.save (err, doc) ->
    return callback err if err 
    callback null

# 回复中提到的发送提醒
replySchema.methods.sendReplyMentionNotification = (user_ids, callback) ->
  reply = @
  async.each user_ids, sendNotification.bind(reply), (err) ->
    return callback err if err 
    return callback null


# 更新时间戳，markdown转换到html
replySchema.pre 'save', (next) ->
  @updated_at = new Date()

  if @isModified 'content' 
    @content_html = lib.replyToHtml(@content)
  next()

mongoose.model 'Reply', replySchema