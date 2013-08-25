mongoose = require 'mongoose'
async = require 'async'

# Get "/"
exports.index = (req, res) ->
  Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')

  async.parallel 
    nodes: (callback) ->
      Plane.allNodes callback
    topics: (callback) ->
      Topic.recentTopics 100, callback
    (err, result) ->
      throw err if err
      res.render "index", planes: result.nodes, topics: result.topics
