mongoose = require 'mongoose'
async = require 'async'

Schema = mongoose.Schema

siteSchema = new Schema

siteSchema.statics.siteInfo = (callback) ->
  Topic = mongoose.model 'Topic'
  User = mongoose.model 'User'
  Reply = mongoose.model 'Reply'
  Node = mongoose.model 'Node'

  async.parallel
    topic_count: (callback) ->
      Topic.count (err, count) ->
        return callback err if err
        callback null, count
    user_count: (callback) ->
      User.count (err, count) ->
        return callback err if err
        callback null, count
    reply_count: (callback) ->
      Reply.count (err, count) ->
        return callback err if err
        callback null, count
    node_count: (callback) ->
      Node.count (err, count) ->
        return callback err if err
        callback null, count
    (err, resaults) ->
      return callback err if err
      callback null, resaults

mongoose.model 'Site', siteSchema
