nodemailer = require "nodemailer"

env = process.env.NODE_ENV or 'development'
settings = require("../settings")(env)

#TODO move to settings
mail_options = 
  host: "smtp.gmail.com"
  secureConnection: true
  port: 465
  auth:
    user: "lidash156@gmail.com"
    pass: "524778989"

smtpTransport = nodemailer.createTransport "SMTP", mail_options

exports.sendActiveMail = (user_email, token, name) ->
  from = mail_options.auth.user
  to = user_email
  subject = "Active Your Account"
  content = "<p>  hello #{name}</p>
  <a href=#{settings.root_url}/active_account?token=#{token}&name=#{name}>Active Account links </a> "

  smtpTransport.sendMail
    from: from
    to: to
    subject: subject
    html: content, (err, response) ->
      if err 
        console.log err 
      else
        console.log response

exports.resetPasswordMail = (user_email, token, name) ->
  from = mail_options.auth.user
  to = user_email
  subject = "reset your password"

