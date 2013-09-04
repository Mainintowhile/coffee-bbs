mongoose = require 'mongoose'
Schema = mongoose.Schema

counterSchema = new Schema
  _id: { type: String, rquired: true, index: { unique: true } }
  count: { type: Number, require: true}

counterSchema.statics.incrementCounter = (schemaName, callback) ->
  @collection.findAndModify _id: schemaName, [], {$inc: count: 1}, "new": true, upsert: true, (err, result)->
    return callback err if err
    callback null, result.count

mongoose.model('Counter', counterSchema)