env = process.env.NODE_ENV or 'development'
settings = require('../config/settings')(env)

qiniu = require 'qiniu'
qiniu.conf.ACCESS_KEY = settings.qiniu.access_key
qiniu.conf.SECRET_KEY = settings.qiniu.secret_key

# upload token for qiniu
exports.upToken = (email_md5) ->
  #config token
  putPolicy = new qiniu.rs.PutPolicy(settings.qiniu.bucket)
  # putPolicy.callbackUrl = "http://#{settings.domain_name}/setting/avatar"
  # putPolicy.callbackBody = "email_md5=#{email_md5}"
  putPolicy.returnUrl = "http://#{settings.domain_name}/setting/avatar"
  putPolicy.returnBody = "true"

  putPolicy.token()

