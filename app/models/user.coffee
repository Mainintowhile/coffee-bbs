mongoose = require 'mongoose'
bcrypt = require 'bcrypt'
crypto = require 'crypto'
env = process.env.NODE_ENV or 'development'
settings = require('../../config/settings')(env)

Schema = mongoose.Schema
SALT_WORK_FACTOR = 10

userSchema = Schema
  username: { type: String, unique: true, required: true, index: { unique: true } }
  password: { type: String, required: true}
  email: { type: String, unique: true, required: true, index: {unique: true}}
  email_md5: {type:String, unique: true, required: true, index: {unique: true}}
  reg_id: { type: Number, unique: true, required: true}
  topic_count: { type: Number, default: 0 }
  reply_count: { type: Number, default: 0 }
  reputation: { type: Number, default: 10 }
  favorite_topics: [{type: Schema.Types.ObjectId, ref: "Topic"}]
  gravatar_type: { type: Number, default: 0} # 0 default, 1 gravatar, 2 upload gravatar
  nickname: String
  signature: String
  location: String
  website: String
  company: String
  github: String
  twitter: String
  douban: String
  self_intro: String
  active: { type: Boolean, default: false}
  confirmation_token: String
  confirmed_at: Date
  reset_password_token: String
  reset_password_sent_at: Date
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }


# encrypted password
userSchema.pre 'save', (next) ->
	user = @
	return next() unless user.isModified('password')
	
	bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->
    return next(err) if err
    bcrypt.hash user.password, salt, (err, hash) ->
      return next(err) if err
      user.password = hash
      next()

# auto updated_time field 
userSchema.pre 'save', (next) ->
  @updated_at = new Date()
  next()

# 生成唯一的id
# 用户是新创建的时候生成id
userSchema.pre 'validate', (next) ->
  if @isNew
    user = @
    Counter = mongoose.model('Counter')
    Counter.incrementCounter "users", (err, res)->
      return next(err) if err
      user.reg_id = res
      next()
  else
    next()

# generate email md5
userSchema.pre 'validate', (next) ->
  if @isNew
    md5 = crypto.createHash 'md5'
    @email_md5 = md5.update(@email.toLowerCase()).digest('hex')
    next()
  else
    next()

userSchema.statics.newUsers = (count, callback) ->
  @find({}).limit(count).sort(created_at: 'desc').exec (err, users) ->
    return callback err if err
    callback null, users

userSchema.statics.activeUsers = (count, callback) ->
  @find({}).limit(count).sort(reputation: 'desc').exec (err, users) ->
    return callback err if err
    callback null, users

# auth password
userSchema.methods.comparePassword = (candidatePassword, callback) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    return callback(err) if err
    callback(null, isMatch)

userSchema.methods.avatarUrl = (size = 'm') ->
  switch size 
    when 'b'
      image_size = 96
    when 'm'
      image_size = 48
    else 
      image_size = 32
  # gravatar 服务
  if @gravatar_type == 1
    "http://www.gravatar.com/avatar/#{@email_md5}?size=#{image_size}"
  # upload 2
  else if @gravatar_type == 2
    "http://#{settings.qiniu.bucket}.qiniudn.com/#{@reg_id}?imageView/1/w/#{image_size}/h/#{image_size}/q/85"
  # default 0 
  else
    "/images/#{size}_default.png"

mongoose.model('User', userSchema)
