mongoose = require 'mongoose'
require './models/plane'
require './models/node'

database = "world"

mongoose.connect("mongodb://localhost/#{database}")

Node = mongoose.model('Node')
Plane = mongoose.model('Plane')

planes = 
  '语言':   [ { name: "JavaScript", key: "js"}, { name: "NodeJS", key: "nodejs"}, { name: "Ruby", key: "ruby"}, { name: "Python", key: "python"}]
  '分享':   [ { name: "开源项目", key: "open"}, { name: "算法", key: "algorithm"}, { name: "数学", key: "math"}, { name: "书籍", key: "book"}, { name: "分享", key: "share"}, { name: "问与答", key: "question"}]
  '编辑器': [ { name: "Sublime", key: "sublime"},  { name: "VIM", key: "vim"}, { name: "Notepad++", key: "notepadd"}]
  'DSL':    [ { name: "CoffeeScript", key: "coffee"}, { name: "Sass", key: "sass"}, { name: "Less", key: "less"}, { name: "Jade", key: "jade"}, { name: "Haml", key: "haml"}]
  '框架':   [ { name: "jQuery", key: "jquery"}, { name: "YUI", key: "yui"}, { name: "Bootstrap", key: "bootstrap"} ,  { name: "Tornado", key: "tornado"}]
  '社区':   [ { name: "意见反馈", key: "feedback"}, { name: "公告", key: "placard"}, { name: "社区开发", key: "dev"},{ name: "帮助", key: "help"}]
  '工具':   [ { name: "Git", key: "git"}, { name: "Nginx", key: "nginx"}, { name: "Apache", key: "apache"}]
  '规范':   [ { name: "W3C", key: "w3c"}, { name: "ECMA", key: "ecma"}, { name: "Script", key: "script"}]


saveToMongo = (planes) ->
  for plane_name of planes
    ((plane_name) ->
      plane = new Plane(name: plane_name)
      # console.log "success plane #{doc.id}-#{doc.name}"
      plane_node_count = planes[plane_name].length
      for node in planes[plane_name]
        ((node) ->
          node_instance = new Node(name: node.name, key: node.key)
          node_instance.save (err, doc) ->
            if err
              console.log "save node-err: #{err}"
            else
              console.log "-save node: #{node.name}"
              plane_node_count--
              plane.nodes.push node_instance
              if plane_node_count <= 0
                plane.save (err, doc) ->
                  if err 
                    console.log err 
                  else
                    console.log "=success save plane: #{doc.name}"
        ) node
    ) plane_name

showFromMongo = (plane_name) ->
  Plane.findOne(name: plane_name).populate('nodes').exec (err, doc) ->
    if err
      console.log err
    else
      console.log doc

showAllFromMongo = () ->
  Plane.find().populate('nodes').exec (err, doc) -> 
    if err
      console.log err
    else  
      console.log doc

showAllFromMongo()

# saveToMongo(planes)

# showFromMongo('语言')
