mongoose = require 'mongoose'
sanitize = require('validator').sanitize
Validator = require('validator').Validator

exports.index = (req, res) ->
  Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')
  Plane.allNodes  (err, nodes) -> 
    return console.log err if err
    Topic.recentTopics 100, (err, topics) ->
      return console.log err if err 
      res.render "topics/index", 
      planes: nodes
      topics: topics

exports.show = (req, res) ->
  Topic = mongoose.model('Topic')
  Topic.findById req.params.id, (err, topic) ->
    res.render "topics/show", 
      title: "show page", topic: topic

exports.new = (req, res) ->
	res.render "topics/new", node_key: req.params.key

# path: nodes/:key/topics
# params :title, :content
# method: post
exports.create = (req, res) ->
  node_key = req.params.key
  title = sanitize(req.body.title).xss()
  content = sanitize(req.body.content).xss()
  notices = []
  notices.push "Please input title" unless title
  notices.push "Please input content "unless content

  unless notices.length == 0
    res.render "topics/new", node_key: node_key, title: title, content: content, notices: notices
  else
    Topic = mongoose.model('Topic')
    # topic = new Topic()
    res.send "title: #{title}, content: #{content}"

exports.update = (req, res) ->
	res.render "topics/show", 
		title : "show page"


exports.edit = (req, res) ->
	res.render "topics/show", 
		title : "show page"

exports.destroy = (req, res) ->
	res.render "topics/show", 
		title : "show page"

