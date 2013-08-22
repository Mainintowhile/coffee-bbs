mongoose = require 'mongoose'
Schema = mongoose.Schema


planeSchema = new Schema(
  name: { type: String, unique: true, required: true}
  nodes: [{type: Schema.Types.ObjectId, ref: "Node"}]
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)

planeSchema.statics.allNodes = (callback)->
  @find().populate('nodes').exec(callback)


mongoose.model("Plane", planeSchema)