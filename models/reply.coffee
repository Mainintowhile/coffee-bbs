mongoose = require 'mongoose'
async = require 'async'
Schema = mongoose.Schema

replySchema = new Schema(
  user_id: { type: Schema.Types.ObjectId, index: true }
  topic_id: { type: Schema.Types.ObjectId, index: true }
  content:  { type: String, required: true }
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)

replySchema.statics.findRepliesByTopicId = (topic_id, callback) ->
  @find(topic_id: topic_id).sort(created_at: 'asc').exec (err, replies) ->
    return callback err if err
    async.map replies, getUser, (err, results) -> 
      return callback err if err
      callback null, results

# Get a reply's user
getUser = (reply, callback) ->
  User = mongoose.model 'User'
  User.findById reply.user_id, (err, user) ->
    return callback err if err 
    reply.user = user
    callback null, reply


mongoose.model 'Reply', replySchema