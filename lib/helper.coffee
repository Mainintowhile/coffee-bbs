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
    switch size 
      when 'b'
        image_size = 96
      when 'm'
        image_size = 48
      else 
        image_size = 32
    # gravatar 服务
    if gravatar_type == 1
      "http://www.gravatar.com/avatar/#{email_md5}?size=#{image_size}"
    # upload 2
    else if gravatar_type == 2
      "http://#{settings.qiniu.bucket}.qiniudn.com/#{email_md5}?imageView/1/w/#{image_size}/h/#{image_size}/q/85"
    # default 0 
    else
      "/images/#{size}_default.png"

  # markdown: (text) ->
  #   marked(text)
