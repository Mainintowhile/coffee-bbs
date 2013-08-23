mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId


topicSchema = new mongoose.Schema(
	user_id: { type: ObjectId, required: true }
	node_id: { type: ObjectId, required: true }
	# node_name: { type: String, required: true }
	title: String
	content: String
	hit: { type: Number, default: 0}
	replies_count: { type: Number, default: 0}
	last_replied_by: String
	last_replied_at: { type: Date, default: Date.now}
	created_at: { type: Date, default: Date.now }
	updated_at: { type: Date, default: Date.now }
)

topicSchema.statics.recentTopics = (count, callback) ->
  @find().limit(count).exec (callback)

topicSchema.pre 'save', (next) ->
  @updated_at = new Date()
  next()

Topic = mongoose.model 'Topic', topicSchema
