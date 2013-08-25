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

mongoose.model("Node", nodeSchema)