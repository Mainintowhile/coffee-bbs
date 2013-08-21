mongoose = require 'mongoose'
Schema = mongoose.Schema


planeSchema = new Schema(
  name: { type: String, unique: true, required: true}
  nodes: [{type: Schema.Types.ObjectId, ref: "Node"}]
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }
)

mongoose.model("Plane", planeSchema)