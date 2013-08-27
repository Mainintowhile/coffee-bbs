mongoose = require 'mongoose'
sanitize = require('validator').sanitize
Validator = require('validator').Validator
async = require 'async'

# Get "/topics"
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

# Get "/topics/:topic_id"
exports.show = (req, res) ->
  Topic = mongoose.model('Topic')
  Reply = mongoose.model('Reply')
  User = mongoose.model('User')
  Node = mongoose.model('Node')

  # get topic
  Topic.findById req.params.id, (err, topic) ->
    throw err if err
    async.parallel
      topic: (callback) ->
        topic.hit++
        topic.save()
        callback()
      replies: (callback) ->
        Reply.findRepliesByTopicId topic.id, (err, replies) ->
          return callback err if err
          callback null, replies
      user: (callback) ->
        User.findById topic.user_id, (err, user) -> 
          return callback err if err
          callback null, user
      node: (callback) ->
        #TODO replace with topic.node methods
        Node.findById topic.node_id, (err, node) ->
          return callback err if err
          callback null, node
      (err, results) ->
        topic.user = results.user
        topic.replies = results.replies
        topic.node = results.node
        res.render "topics/show", 
          title: "show page", topic: topic

# GET /nodes/:key/new
exports.new = (req, res) ->
	res.render "topics/new", node_key: req.params.key

# POST /nodes/:key/topics
exports.create = (req, res) ->
  node_key = req.params.key
  user_id = req.session.user._id
  title = sanitize(req.body.title).xss()
  content = sanitize(req.body.content).xss()
  notices = []
  notices.push "Please input title" unless title
  notices.push "Please input content "unless content

  unless notices.length == 0
    res.render "topics/new", node_key: node_key, title: title, content: content, notices: notices
  else
    Node = mongoose.model('Node')
    Topic = mongoose.model('Topic')
    User = mongoose.model('User')

    Node.findNodeByKey node_key, (err, node) ->
      throw err if err 
      async.parallel
        topic: (callback) ->
          topic = new Topic {title: title, content: content, node_id: node.id, user_id: user_id }
          topic.save (err, topic) ->
            return callback err if err 
            callback null, topic
        user: (callback) ->
          User.findById user_id, (err, user) ->
            user.topic_count++
            user.save (err, doc) ->
              return callback err if err 
              callback null, doc
        node: (callback) ->
          node.topic_count++
          node.save (err, doc) ->
            return callback err if err 
            callback null, doc
        (err, results) ->
          throw err if err 
          res.redirect "/topics/#{results.topic.id}"

# POST /topics/:id/favorite
exports.favorite = (req, res) ->
  topic_id = req.params.id
  User = mongoose.model 'User'
  Topic = mongoose.model 'Topic'

  User.findById req.session.user._id, (err, user) ->
    throw err if err 
    Topic.findById topic_id, (err, topic) ->
      throw err if err 
      if topic.id.toString() in user.favorite_topics.map((id) -> id.toString())
        return res.json { success: 0, message: 'already_favorited' }
      if topic.user_id.toString() == user.id.toString()
        return res.json { success: 0, message: 'can_not_favorite_your_topic' }
      user.favorite_topics.push topic.id
      user.save (err, doc) ->
        throw err if err 
        res.json { success: 1 }

# POST /topics/:id/unfavorite
exports.unfavorite = (req, res) ->
  topic_id = req.params.id
  User = mongoose.model 'User'

  User.findById req.session.user._id, (err, user) ->
    throw err if err 
    if topic_id in user.favorite_topics.map((id) -> id.toString())
      user.favorite_topics.remove(topic_id)
      user.save (err, doc) ->
        throw err if err 
        res.json { success: 1}
    else 
      res.json { success: 0, message: 'topic_not_exist' }

# 
exports.update = (req, res) ->
	res.render "topics/show", 
		title : "show page"

exports.edit = (req, res) ->
	res.render "topics/show", 
		title : "show page"

exports.destroy = (req, res) ->
	res.render "topics/show", 
		title : "show page"

