crypto = require 'crypto'

module.exports = {
  avatar: (email) ->
   md5 = crypto.createHash 'md5'
   email_MD5 = md5.update(email.toLowerCase()).digest('hex')
   "http://www.gravatar.com/avatar/#{email_MD5}?s=48"
 }