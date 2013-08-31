marked = require 'marked'

marked.setOptions
  gfm: true
  breaks: true
  sanitize: false 

# 处理 #12楼 => <a href="#reply12">12楼</a>
replaceFloor = (text) ->
  replyFloorRegexp = /#(\d+)\u697c/g
  text = text.replace replyFloorRegexp, "<a href=#reply$1 class='at_floor'>#$1楼</a>"
  return text

# 处理 @hello => <a href="/u/hello"> hello </a>
replaceMention = (text) ->
    mentionRegexp = /@([a-zA-Z0-9_]{1,20})\s/g
    text = text.replace mentionRegexp, "@<a href=/u/$1 class='at_user'>$1 </a>"
    return text

# 处理图片链接 
replaceImageUrl = (text) ->
  imageUrl = /(https?:\/\/.*\.(?:png|jpg))/gi
  text = text.replace imageUrl, "<img src=$1>"

# 回复内容转换到html
exports.replyToHtml = (text) ->
  text = replaceMention replaceFloor(text)
  text = replaceImageUrl text
  marked(text)

# 主题内容转换到html
exports.topicToHtml = (text) ->
  text = replaceMention text
  text = replaceImageUrl text
  marked(text)

# 获取文本中提到的用户名，返回数组
exports.findMentionUsers = (content) ->
  re = /@([a-zA-Z0-9]{1,20})/g
  mentioned_users = content.match(re)
  if mentioned_users != null
    # 去重
    output = {}
    output[mentioned_users[key]] = mentioned_users[key] for key in [0...mentioned_users.length]
    value.replace(/@/, '') for key, value of output
  else
    []