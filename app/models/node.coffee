mongoose = require 'mongoose'
Schema = mongoose.Schema

nodeSchema = new Schema(
  name: { type: String, unique: true, required: true }
  key: { type: String, unique: true, required: true }
  intro: String
  topic_count: { type: Number, default: 0}
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)

nodeSchema.statics.findNodeByKey = (key, callback) ->
  @findOne key: key, (err, node) ->
    return callback err if err
    callback null, node

nodeSchema.statics.hotNodes = (count,  callback) ->
  @find({}).limit(count).sort(topic_count: 'desc').exec (err, nodes) ->
    return callback err if err
    callback null, nodes

nodeSchema.methods.topicsCount = (callback) ->
  self = @
  Topic = mongoose.model 'Topic'
  Topic.count node_id: self.id, (err, count) ->
    return callback err if err
    callback null, count

mongoose.model("Node", nodeSchema)
