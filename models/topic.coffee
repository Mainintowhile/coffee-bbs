mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId


topicSchema = new mongoose.Schema(
	user_id: { type: ObjectId, ref: 'User' }
	node_id: { type: ObjectId, ref: 'Node' }
	title: String
	content: String
	# comments: [{type: Schema.Types.ObjectId, ref: "Comment"}]
	hit: { type: Number, default: 0}
	last_replied_by: String
	last_replied_at: { type: Date, default: Date.now}
	created_at: { type: Date, default: Date.now }
	updated_at: { type: Date, default: Date.now }
)

topicSchema.statics.recentTopics = (count, callback) ->
  @find().limit(count).exec (callback)

Topic = mongoose.model 'Topic', topicSchema
# module.exports = Topic