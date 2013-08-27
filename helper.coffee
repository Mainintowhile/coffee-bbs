# view helper 
crypto = require 'crypto'
moment = require "moment"
moment.lang('zh-cn')

module.exports =
  avatar: (email_md5) ->
    "http://www.gravatar.com/avatar/#{email_md5}?s=48"

  human_datetime: (datetime) -> moment(datetime).fromNow()
  
  human_date: (date) -> moment(date).format("YYYY-MM-DD")

 #  momentTime: ->
 #    moment.apply(null, arguments)
