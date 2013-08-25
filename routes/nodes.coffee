mongoose = require 'mongoose'
# sanitize = require('validator').sanitize


exports.index = (req, res) ->
  res.send "#{req.params.name}"

exports.show = (req, res) ->
  Node = mongoose.model('Node')
  Topic = mongoose.model('Topic')

  Node.findNodeByKey req.params.key, (err, node) ->
    throw err if err
    Topic.findTopicsByNode node.id, 100, (err, topics) ->
      throw err if err
      res.render 'nodes/show',
        node: node
        topics: topics
