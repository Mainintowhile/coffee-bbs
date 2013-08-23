mongoose = require 'mongoose'
Schema = mongoose.Schema

replySchema = new Schema(
  user_id: Schema.Types.ObjectId
  topic_id: Schema.Types.ObjectId
  username: { type: String, required: true }
  content:  { type: String, required: true }
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)


mongoose.model 'Reply', replySchema