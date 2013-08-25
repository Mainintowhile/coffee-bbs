mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

topicSchema = new mongoose.Schema(
	user_id: { type: ObjectId, required: true }
	node_id: { type: ObjectId, required: true }
	title: String
	content: String
	hit: { type: Number, default: 0}
	replies_count: { type: Number, default: 0}
	last_replied_by: String
	last_replied_at: { type: Date, default: Date.now}
	created_at: { type: Date, default: Date.now }
	updated_at: { type: Date, default: Date.now }
)

topicSchema.statics.recentTopics = (count, callback) ->
  @find().limit(count).exec callback

# topicSchema.statics.recentTopics = (count, callback) ->
#   @find().limit(count).exec (err, topics) ->
#     return callback err if err 
#     topics_count = topics.length 

#     topics.forEach (topic) ->
#       topics_count--
#       topic.author (err, author) ->
#         return callback err if err 
#         console.log "author is #{author}"
#         topic.user = author
#         if topics_count == 0
#           callback null, topics


topicSchema.methods.author = (callback) ->
  User = mongoose.model 'User'
  User.findById @user_id, (err, user) ->
    if err
      callback err
    else
      callback null, user

topicSchema.methods.node = (callback) ->
  Node = mongoose.model 'Node'
  Node.findById @node_id, (err, node) ->
    if err 
      callback err
    else
      callback null, node


topicSchema.pre 'save', (next) ->
  @updated_at = new Date()
  next()

# update user topics_count field
# topicSchema.post 'save', (topic) ->
  # console.log "post is be saved: #{topic}"
  # console.log "this is: #{@}"
  # if @isNew
  #   User = mongoose.model 'User'
  #   User.findById topic.user_id, (err, user) ->
  #     throw err if err
  #     user.topics_count++
  #     user.save()

# update user topics_count when doc remove
# topicSchema.post 'remove', (topic) ->
#   User = mongoose.model 'User'
#   User.findById topic.user_id, (err, user) ->
#     throw err if err
#     user.topics_count--
#     user.save()


Topic = mongoose.model 'Topic', topicSchema
