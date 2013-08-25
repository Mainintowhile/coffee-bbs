mongoose = require 'mongoose'
sanitize = require('validator').sanitize
Validator = require('validator').Validator
async = require 'async'

exports.index = (req, res) ->
  Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')

  async.parallel
    nodes: (callback) ->
      Plane.allNodes callback
    topics: (callback) ->
      Topic.recentTopics 100, callback
    (err, results) ->
      throw err if err
      res.render "topics/index", planes: results.nodes, topics: results.topics

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
        Node.findById topic.node_id, (err, node) ->
          return callback err if err
          callback null, node
      (err, results) ->
        topic.user = results.user
        topic.replies = results.replies
        topic.node = results.node
        res.render "topics/show", 
          title: "show page", topic: topic

exports.new = (req, res) ->
	res.render "topics/new", node_key: req.params.key

# POST nodes/:key/topics
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
      topic = new Topic {title: title, content: content, node_id: node.id, user_id: user_id }
      topic.save (err, topic) ->
        throw err if err 
        User.findById topic.user_id, (err, user) ->
          user.topic_count++
          user.save()
        node.topic_count++
        node.save()
        res.redirect "/topics/#{topic.id}"

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

