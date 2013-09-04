# view helper 
crypto = require 'crypto'
moment = require "moment"
marked = require 'marked'

moment.lang('zh-cn')

module.exports =
  avatar: (email_md5) ->
    "http://www.gravatar.com/avatar/#{email_md5}?s=48"

  humanDatetime: (datetime) -> moment(datetime).fromNow()
  
  humanDate: (date) -> moment(date).format("YYYY-MM-DD")

  userAvatarUrl: (gravatar_type, email_md5, size = 'm') ->
    # gravatar 服务
    if gravatar_type == 1
      switch size
        when 'b'
          "http://www.gravatar.com/avatar/#{email_md5}?size=96"
        when 'm'
          "http://www.gravatar.com/avatar/#{email_md5}?size=48"
        else
          "http://www.gravatar.com/avatar/#{email_md5}?size=32"
    else if gravatar_type == 2
      "/images/avatar/#{size}_#{email_md5}.png"
    else
      "/images/#{size}_default.png"

  markdown: (text) ->
    marked(text)
