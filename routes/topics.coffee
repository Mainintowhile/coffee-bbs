mongoose = require 'mongoose'
sanitize = require('validator').sanitize
Validator = require('validator').Validator

exports.index = (req, res) ->
  Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')

  Plane.allNodes  (err, nodes) -> 
    return throw err if err
    Topic.recentTopics 100, (err, topics) ->
      return console.log err if err 
      res.render "topics/index", planes: nodes, topics: topics

exports.show = (req, res) ->
  Topic = mongoose.model('Topic')
  Reply = mongoose.model('Reply')
  User = mongoose.model('User')

  # get topic
  Topic.findById req.params.id, (err, topic) ->
    return throw err if err
    topic.hit++
    topic.save()

    # get topic replies
    Reply.find topic_id: topic.id, (err, replies) ->
      return throw err if err
      topic.replies = replies

      # get topic create user
      User.findById topic.user_id, (err, user) -> 
        return throw err if err
        topic.user = user
        res.render "topics/show", 
          title: "show page", topic: topic

exports.new = (req, res) ->
	res.render "topics/new", node_key: req.params.key

# @path: nodes/:key/topics
# @params :title, :content
# @method: post
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
    Node.findNodeByKey node_key, (err, node) ->
      return console.log err if err 
      topic = new Topic {title: title, content: content, node_id: node.id, user_id: user_id }
      topic.save (err, topic) ->
        return console.log err if err
        node.topic_count++
        node.save (err, doc) ->
          return console.log err if err 
          res.redirect "/topics/#{topic.id}"


exports.update = (req, res) ->
	res.render "topics/show", 
		title : "show page"


exports.edit = (req, res) ->
	res.render "topics/show", 
		title : "show page"

exports.destroy = (req, res) ->
	res.render "topics/show", 
		title : "show page"

