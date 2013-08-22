mongoose = require 'mongoose'

# Get "/"
exports.index = (req, res) ->
  # Topic = mongoose.model('Topic')
  Plane = mongoose.model('Plane')

  Plane.allNodes (err, doc) -> 
    if err
      console.log err
      res.send "some err"
    else  
      res.render "index", 
        planes: doc
