marked = require 'marked'

marked.setOptions
  gfm: true
  breaks: true
  sanitize: false 

# 处理 #12楼 => <a href="#reply12">12楼</a>
replaceFloor = (text) ->
  console.log "text is: #{text}"
  replyFloorRegexp = /#(\d+)\u697c/g
  text = text.replace replyFloorRegexp, "<a href=#reply$1 class='at_floor'>#$1楼</a>"
  console.log "text is: #{text}"
  return text

# 处理 @hello => <a href="/u/hello"> hello </a>
replaceMention = (text) ->
    console.log "text is: #{text}"
    mentionRegexp = /@([a-zA-Z0-9_]{1,20})\s/g
    text = text.replace mentionRegexp, "<a href=/u/$1 class='at_user'> @$1 </a>"
    console.log "text is: #{text}"
    return text

# 处理图片链接 
replaceImageUrl = (text) ->
  imageUrl = /(https?:\/\/.*\.(?:png|jpg))/gi
  text = text.replace imageUrl, "<img src=$1>"

exports.replyToHtml = (text) ->
  text = replaceMention replaceFloor(text)
  text = replaceImageUrl text
  marked(text)

exports.topicToHtml = (text) ->
  text = replaceMention text
  text = replaceImageUrl text
  marked(text)

# exports.findMentionUsers = (text) ->
#   re = /@([a-zA-Z0-9]{1,20})/g
#   mentioned_users = text.match(re)
#   if mentioned_users != null
#     user.replace(/@/, '') for user in mentioned_users
#   else
#     null