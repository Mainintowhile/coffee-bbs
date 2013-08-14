nodemailer = require "nodemailer"
settings = require("../settings")('development')
#TODO get env
mail_options = 
  host: "smtp.gmail.com"
  secureConnection: true
  port: 465
  auth:
    user: "lidash156@gmail.com"
    pass: "524778989"

smtpTransport = nodemailer.createTransport "SMTP", mail_options

# params: email mail receive 
# params: token hash token string 
# params: name user name
exports.sendActiveMail = (user_email, token, name) ->
  from = mail_options.auth.user
  to = user_email
  subject = "Active Your Account"
  content = "<p>  hello </p>
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
