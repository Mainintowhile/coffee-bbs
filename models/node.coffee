mongoose = require 'mongoose'
Schema = mongoose.Schema

nodeSchema = new Schema(
	name: String
	key: String
	introduction: String
	topic_count: { type: Number, default: 0}
	created_at: { type: Date, default: Date.now }
	updated_at: { type: Date, default: Date.now }
)
