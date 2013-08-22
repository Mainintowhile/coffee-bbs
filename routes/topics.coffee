mongoose = require 'mongoose'

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


exports.new = (req, res) ->
	res.render "topics/new", 
		title : "new page"

exports.show = (req, res) ->
  Topic = mongoose.model('Topic')
  Topic.findById req.params.id, (err, topic) ->
	  res.render "topics/show", 
			title: "show page", topic: topic

exports.create = (req, res) ->
	res.render "topics/show", 
		title : "show page"

exports.update = (req, res) ->
	res.render "topics/show", 
		title : "show page"


exports.edit = (req, res) ->
	res.render "topics/show", 
		title : "show page"

exports.destroy = (req, res) ->
	res.render "topics/show", 
		title : "show page"

