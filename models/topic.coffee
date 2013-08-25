mongoose = require 'mongoose'
async = require 'async'

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

topicSchema = new mongoose.Schema(
	user_id: { type: ObjectId, required: true, index: true }
	node_id: { type: ObjectId, required: true , index: true }
	title: String
	content: String
	hit: { type: Number, default: 0}
	replies_count: { type: Number, default: 0}
	last_replied_by: String
	last_replied_at: { type: Date, default: Date.now}
	created_at: { type: Date, default: Date.now }
	updated_at: { type: Date, default: Date.now }
)

# Find Topics with Node  by node_id
topicSchema.statics.findTopicsByNode = (node_id, count, callback) ->
  @find({node_id: node_id}).limit(count).sort(created_at: 'desc').exec (err, topics) ->
    async.map topics, getUser, (err, results) ->
      return callback err if err 
      callback null, topics

# Find Topic with Node with user_id
topicSchema.statics.findTopicsByUserId= (user_id, count, callback) ->
  @find({user_id: user_id}).limit(count).sort(created_at: 'desc').exec (err, topics) ->
    async.map topics, getNode, (err, results) ->
      return callback err if err 
      callback null, results

# Find recent Topics
topicSchema.statics.recentTopics = (count, callback) ->
  @find().limit(count).sort(created_at: 'desc').exec (err, topics) ->
    async.waterfall [
      (cb) ->
        async.map topics, getUser, (err, results) ->
          return cb err if err
          cb null, results
      (topics, cb) ->
        async.map topics, getNode, (err, results) ->
          return cb err if err
          cb null, results
    ],
    (err, results) ->
      return callback err if err
      callback null, results

getUser = (topic, callback) ->
  User = mongoose.model 'User'
  User.findById topic.user_id, (err, user) ->
    return callback err if err
    topic.user = user
    callback null, topic

getNode = (topic, callback) ->
  Node = mongoose.model 'Node'
  Node.findById topic.node_id, (err, node) ->
    return callback err if err
    topic.node = node
    callback null, topic

topicSchema.methods.node = (callback) ->
  Node = mongoose.model 'Node'
  Node.findById @node_id, (err, node) ->
    return callback err if err
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
