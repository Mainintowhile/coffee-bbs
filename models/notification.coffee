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


mongoose.model 'Notification', notificationSchema
