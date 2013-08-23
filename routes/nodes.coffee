mongoose = require 'mongoose'
# sanitize = require('validator').sanitize


exports.index = (req, res) ->
  res.send "#{req.params.name}"

exports.show = (req, res) ->
  Node = mongoose.model('Node')
  Node.findNodeByKey req.params.key, (err, node) ->
    res.render 'nodes/show',
      node: node
