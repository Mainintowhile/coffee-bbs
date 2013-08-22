mongoose = require 'mongoose'
Schema = mongoose.Schema


nodeSchema = new Schema(
  name: { type: String, unique: true, required: true }
  key: { type: String, unique: true, required: true }
  intro: String
  topics: [{type: Schema.Types.ObjectId, ref: "Topic"}]
  topic_count: { type: Number, default: 0}
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)

nodeSchema.statics.findByKeyWithTopics = (key, callback) ->
  @findOne(key: key).populate('topics').exec (err, node) ->
    return callback err if err 
    callback null, node

mongoose.model("Node", nodeSchema)