mongoose = require 'mongoose'

# Get "/"
exports.index = (req, res) ->
  # Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')

  # Topic.find().limit(100).exec (err, coll) ->
  #   res.render "index", 
  #     topics: coll
  
  Plane.find().populate('nodes').exec (err, doc) -> 
    if err
      console.log err
      res.send "some err"
    else  
      res.render "index", 
        planes: doc
