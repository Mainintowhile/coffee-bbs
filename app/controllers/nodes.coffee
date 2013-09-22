mongoose = require 'mongoose'
async = require 'async'

# GET /nodes/:key 
exports.show = (req, res, next) ->
  Node = mongoose.model('Node')
  Topic = mongoose.model('Topic')

  Node.findNodeByKey req.params.key, (err, node) ->
    throw err if err
    return next() unless node

    async.parallel
      # 主题数
      topicsCount: (callback) ->
        node.topicsCount (err, count) ->
          return callback err if err
          callback null, count
      # 主题列表
      topics: (callback) ->
        node.topicsList 100, (err, topics) ->
          return callback err if err
          callback null, topics
      (err, results) ->
        throw err if err
        res.render 'nodes/show', node: node, topics: results.topics, topicsCount: results.topicsCount
