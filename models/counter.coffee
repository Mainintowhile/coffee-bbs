mongoose = require 'mongoose'
Schema = mongoose.Schema

counterSchema = new Schema
  _id: { type: String, rquired: true, index: { unique: true } }
  count: { type: Number, require: true}

counterSchema.statics.incrementCounter = (schemaName, callback) ->
  # @collection.findAndModify query, sort, doc, options, callback
  @collection.findAndModify {_id: schemaName}, [], {$inc: count: 1}, "new": true, upsert:true, (err, result)->
    if err
      callback err
    else
      callback null, result.count

mongoose.model('Counter', counterSchema)



