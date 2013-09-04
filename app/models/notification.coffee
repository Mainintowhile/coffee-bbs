mongoose = require 'mongoose'
async = require 'async'


Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

# notification 
# action 提醒的类型 reply, reply_mention, topic_mention
notificationSchema = new mongoose.Schema
  user_id: { type: ObjectId, required: true, index: true }
  # notifiable_type: { type: String }
  # notifiable_id 等于 topic.id
  notifiable_id: { type: ObjectId, required: true,}
  action: { type: String }
  # 发送者，既回复者
  action_user_id: { type: ObjectId, required: true }
  content: { type: String }
  status: { type: Boolean, default: false }
  created_at: { type: Date, default: Date.now }

# 获取用户未读提醒数
notificationSchema.statics.unreadCount = (user_id, callback) ->
  @count status: false, user_id: user_id, (err, count) ->
    return callback err if err 
    callback null, count

# 获取用户提醒
notificationSchema.statics.getByUser =  (conditions, options, callback) ->
  @find conditions, null, options, (err, notifications) ->
    return callback err if err
    # 获取发送者信息,主题信息 
    async.waterfall [
      (next) ->
        async.map  notifications, getActionUser, (err, results) ->
          return next err if err 
          next null, results
      (notifications, next) -> 
        async.map notifications, getMentionTopic, (err, results) ->
          return next err if err 
          next null, results
    ], 
    (err, results) ->
      return callback err if err 
      callback null, results

# 获取提醒主题信息
getMentionTopic = (notification, callback) ->
  Topic = mongoose.model 'Topic'
  Topic.findById notification.notifiable_id, 'title content_html', (err, topic) ->
    return callback err if err 
    notification.topic = topic
    callback null, notification

# 获取发送者的信息
getActionUser = (notification, callback) ->
  User = mongoose.model 'User'
  #TODO 部分field
  User.findById notification.action_user_id, (err, user) ->
    return callback err if err 
    notification.user = user
    callback null, notification

mongoose.model 'Notification', notificationSchema
