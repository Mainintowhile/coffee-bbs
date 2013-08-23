crypto = require 'crypto'
moment = require "moment"

module.exports = {
  avatar: (email_md5) ->
    "http://www.gravatar.com/avatar/#{email_md5}?s=48"

  momentTime: ->
    moment.apply(null, arguments)
 }
