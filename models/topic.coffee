mongoose = require 'mongoose'
async = require 'async'

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

topicSchema = new mongoose.Schema
  user_id: { type: ObjectId, required: true, index: true }
  node_id: { type: ObjectId, required: true , index: true }
  title: { type: String }
  content: { type: String }
  username: { type: String } # for cache
  hit: { type: Number, default: 0}
  vote_users: [{ type: ObjectId, ref: "User" }]
  replies_count: { type: Number, default: 0}
  last_replied_by: String
  last_replied_at: { type: Date, default: Date.now}
  created_at: { type: Date, default: Date.now }
  updated_at: { type: Date, default: Date.now }

# 获取 topic 列表, 并获取 user 和 node 信息
# 参数 conditions:查询条件, options: 选项, callback:回调
topicSchema.statics.getTopicListWithNodeUser = (conditions, options, callback) ->
  @find conditions, '-content', options, (err, topics) ->
    return callback err if err
    async.waterfall [
      (next) ->
        async.map topics, getUser, (err, results) ->
          return next err if err
          next null, results
      (topics, next) ->
        async.map topics, getNode, (err, results) ->
          return next err if err
          next null, results
    ],
    (err, results) ->
      return callback err if err
      callback null, results

# 通过 node_id 获取 topic 列表 
# 并获取 topic 用户信息, ex: node/show 页面
topicSchema.statics.getTopicListWithUser = (node_id, count, callback) ->
  @find({node_id: node_id}).limit(count).select('-content').sort(last_replied_at: -1).exec (err, topics) ->
    async.map topics, getUser, (err, results) ->
      return callback err if err 
      callback null, topics

# 通过 user_id 获取 topic 列表
# 并获取 topic 节点信息 ex: user/topic 页面
topicSchema.statics.getTopicListWithNode = (user_id, count, callback) ->
  @find({user_id: user_id}).limit(count).sort(created_at: -1).exec (err, topics) ->
    async.map topics, getNode, (err, results) ->
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

# Find recent Topics
# example topics index page
# topicSchema.statics.recentTopicsList = (count, callback) ->
#   @find().limit(count).select('-content').sort(last_replied_at: -1).exec (err, topics) ->
#     async.waterfall [
#       (next) ->
#         async.map topics, getUser, (err, results) ->
#           return next err if err
#           next null, results
#       (topics, next) ->
#         async.map topics, getNode, (err, results) ->
#           return next err if err
#           next null, results
#     ],
#     (err, results) ->
#       return callback err if err
#       callback null, results

# get topic with Node topic ids
#TODO
# topicSchema.statics.getTopicsWithNodeByIds = (topic_ids, callback) ->
#   @find(_id: $in: topic_ids).select('-content').sort(created_at: -1).exec (err, topics) ->
#     async.waterfall [
#       (next) ->
#         async.map topics, getUser, (err, results) ->
#           return next err if err
#           next null, results
#       (topics, next) ->
#         async.map topics, getNode, (err, results) ->
#           return next err if err
#           next null, results
#     ],
#     (err, results) ->
#       return callback err if err
#       callback null, results
      
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


mongoose.model 'Topic', topicSchema
