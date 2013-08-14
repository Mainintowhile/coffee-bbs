mongoose = require 'mongoose'
Schema = mongoose.Schema
bcrypt = require 'bcrypt'
SALT_WORK_FACTOR = 10

UserSchema = Schema
  username: { type: String, required: true, index: { unique: true } }
  password: { type: String, required: true}
  email: { type: String, required: true}
  reg_id: Number
  avatar: String
  active: { type: Boolean, default: false}
  confirmation_token: String
  confirmed_at: Date
  confirmation_send_at: Date
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
      user.password = hash;
      next();

# auth password
UserSchema.methods.comparePassword = (candidatePassword, callback) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    return callback(err) if err 
    callback(null, isMatch)

module.exports = mongoose.model('User', UserSchema)
