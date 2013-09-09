CoffeeCup
=========

CoffeeCup - a simple bbs base Node.js & express
基于Node.js express框架的论坛程序

* express 3
* coffeescript 
* jade
* mongoose 


## Install 

需要安装mongodb, redis, nodejs

config/settings.coffee 必需要配置的部分

`mail_options:` 可以使用mailgun.com 的服务

`qiniu`: 七牛云存储


appfog 可以直接部署

    af update coffeecup 
    
服务器部署安装依赖包,在项目目录里

    npm install 
    
安装coffeescript

    sudo npm install -g coffee-scirpt

coffee -> js

    coffee -c ./
    
推荐使用pm2部署

* http://devo.ps/blog/2013/06/26/goodbye-node-forever-hello-pm2.html
* github https://github.com/Unitech/pm2




