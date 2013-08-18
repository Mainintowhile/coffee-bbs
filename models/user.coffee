mongoose = require 'mongoose'
bcrypt = require 'bcrypt'
crypto = require 'crypto'

Schema = mongoose.Schema
SALT_WORK_FACTOR = 10

UserSchema = Schema
  username: { type: String, required: true, index: { unique: true } }
  password: { type: String, required: true}
  email: { type: String, required: true, index: {unique: true}}
  # reg_id: { type: Number, required: true}
  reg_id: Number
  nickname: String
  signature: String
  location: String
  website: String
  company: String
  github: String
  twitter: String
  douban: String
  self_intro: String
  avatar: String
  active: { type: Boolean, default: false}
  confirmation_token: String
  confirmed_at: Date
  reset_password_token: String
  reset_password_sent_at: Date
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }


# encrypted password
UserSchema.pre 'save', (next) ->
	user = this
	return next() unless user.isModified('password')
	
	bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) -> 
    return next(err) if err
    bcrypt.hash user.password, salt, (err, hash) ->
      return next(err) if err
      user.password = hash
      next()

UserSchema.pre 'save', (next) ->
  @updated_at = new Date()
  next()

# auth password
UserSchema.methods.comparePassword = (candidatePassword, callback) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    return callback(err) if err 
    callback(null, isMatch)

UserSchema.methods.avatarUrl = (size) ->
  if @avatar
    @avatar
  else
    md5 = crypto.createHash 'md5'
    email_MD5 = md5.update(@email.toLowerCase()).digest('hex')
    "http://www.gravatar.com/avatar/#{email_MD5}?s=#{size}"


module.exports = mongoose.model('User', UserSchema)
