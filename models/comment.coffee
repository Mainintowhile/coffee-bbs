mongoose = require 'mongoose'
Schema = mongoose.Schema

commentSchema = new Schema(
	user_id: Schema.Types.ObjectId
	topic_id: Schema.Types.ObjectId
	content: String
	created_at: { type: Date, default: Date.now }
	updated_at: { type: Date, default: Date.now }
)