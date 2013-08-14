mongoose = require 'mongoose'

# Get "/"
exports.index = (req, res) ->
  Topic = mongoose.model('Topic')

  Topic.find().limit(100).exec (err, coll) ->
    res.render "index",
      title: "index page", topics: coll