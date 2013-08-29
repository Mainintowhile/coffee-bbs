mongoose = require 'mongoose'

# exports.index = (req, res) ->
#   res.send "#{req.params.name}"

exports.show = (req, res, next) ->
  Node = mongoose.model('Node')
  Topic = mongoose.model('Topic')

  Node.findNodeByKey req.params.key, (err, node) ->
    throw err if err
    return next() unless node
    Topic.getTopicListWithUser node.id, 100, (err, topics) ->
      throw err if err
      res.render 'nodes/show', node: node, topics: topics
