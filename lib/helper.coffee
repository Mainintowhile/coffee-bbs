# view helper 
crypto = require 'crypto'
moment = require "moment"
marked = require 'marked'
env = process.env.NODE_ENV or 'development'
settings = require('../config/settings')(env)

moment.lang('zh-cn')

module.exports =
  avatar: (email_md5) ->
    "http://www.gravatar.com/avatar/#{email_md5}?s=48"

  humanDatetime: (datetime) -> moment(datetime).fromNow()
  
  humanDate: (date) -> moment(date).format("YYYY-MM-DD")

  userAvatarUrl: (user, size = 'm') ->
    switch size 
      when 'b'
        image_size = 96
      when 'm'
        image_size = 48
      else 
        image_size = 32
    # gravatar 服务
    if user.gravatar_type == 1
      "http://www.gravatar.com/avatar/#{user.email_md5}?size=#{image_size}"
    # upload 2
    else if user.gravatar_type == 2
      "http://#{settings.qiniu.bucket}.qiniudn.com/#{user.reg_id}?imageView/1/w/#{image_size}/h/#{image_size}/q/85"
    # default 0 
    else
      "/images/#{size}_default.png"

  # markdown: (text) ->
  #   marked(text)
  hiddenEmail: (email) ->
    email.substring(0, 2) + "**" + email.substring(4, email.length)

