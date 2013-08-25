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

# get reply by topic id and append user info
# @params topic_id, callback
replySchema.statics.findRepliesByTopicId = (topic_id, callback) ->
  @find(topic_id: topic_id).sort(created_at: 'asc').exec (err, replies) ->
    return callback err if err
    async.map replies, getUser, (err, results) -> 
      return callback err if err
      callback null, results

# get reply by userid and append topic info
# @params user_id, count, callback
replySchema.statics.findReplyByUserWithTopic = (user_id, count, callback) ->
  @find(user_id: user_id).limit(count).sort(created_at: 'asc').exec (err, replies) ->
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
    (cb) ->
      Topic.findById reply.topic_id, (err, topic) ->
        return cb err if err
        cb null, topic
    (topic, cb) ->
      User.findById topic.user_id, (err, user) ->
        return cb err if err
        cb null, topic, user
  ],
  (err, topic, user) ->
    return callback err if err
    topic.user = user
    reply.topic = topic
    callback null, reply

mongoose.model 'Reply', replySchema