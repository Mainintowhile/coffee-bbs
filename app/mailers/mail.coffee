nodemailer = require "nodemailer"

env = process.env.NODE_ENV or 'development'
settings = require("../../config/settings")(env)


smtpTransport = nodemailer.createTransport "SMTP", settings.mail_options

# 发送激活邮件
exports.sendActiveMail = (user_email, token, name, host_name) ->
  content = "<p>  你好 #{name}</p> 请点击激活链接激活你的帐号 <br /> <a href=http://#{host_name}/active_account?name=#{name}&token=#{token}> 激活链接 </a> "

  smtpTransport.sendMail
    from: settings.mail_options.auth.user
    to: user_email
    subject: "激活帐号"
    html: content, (err, response) ->
      return console.log err if err
      console.log response

#  重置密码邮件
exports.resetPasswordMail = (user_email, token, name, host_name) ->
  content = " 请点击重置密码链接进入重置密码页 <br /> <a href=http://#{host_name}/reset?name=#{name}&token=#{token}>重置密码</a> "

  smtpTransport.sendMail
    from: settings.mail_options.auth.user
    to: user_email
    subject: "重置密码"
    html: content, (err, response) ->
      return console.log err if err
      console.log response


