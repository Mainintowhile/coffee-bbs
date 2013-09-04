mongoose = require 'mongoose'
async = require 'async'

# Get "/"
exports.index = (req, res) ->
  Topic = mongoose.model 'Topic'
  Plane = mongoose.model 'Plane'
  Node = mongoose.model 'Node'
  Site = mongoose.model 'Site'
  
  async.parallel
    nodes: (callback) ->
      Plane.allNodes (err, nodes) ->
        return callback err if err
        callback null, nodes
    topics: (callback) ->
      options = { sort: last_replied_at: -1, limit: 100 }
      Topic.getTopicListWithNodeUser {}, options, (err, topics) ->
        return callback err if err
        callback null, topics
    hotNodes: (callback) ->
      Node.hotNodes 15, (err, hotNodes) ->
        return callback err if err
        callback null, hotNodes
    siteInfos: (callback) ->
      Site.siteInfo (err, infos) ->
        return callback err if err
        callback null, infos
    (err, results) ->
      throw err if err
      res.render "index",
        planes: results.nodes
        topics: results.topics
        hotNodes: results.hotNodes
        siteInfos: results.siteInfos
