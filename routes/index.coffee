mongoose = require 'mongoose'

# Get "/"
exports.index = (req, res) ->
  Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')

  Plane.allNodes  (err, nodes) -> 
    throw err if err
    Topic.recentTopics 100, (err, topics) ->
      throw err if err
      res.render "index", planes: nodes, topics: topics
