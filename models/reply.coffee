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


replySchema.pre 'save', (next) ->
  @updated_at = new Date()
  if @isModified 'content' 
    @content_html = lib.replyToHtml(@content)
  next()

mongoose.model 'Reply', replySchema