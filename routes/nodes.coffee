# mongoose = require 'mongoose'
# sanitize = require('validator').sanitize


exports.index = (req, res) ->
  res.send "#{req.params.key}"

exports.show = (req, res) ->
  res.render 'nodes/show'
