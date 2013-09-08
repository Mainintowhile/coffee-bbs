settings =
  development:
    mongo: "mongodb://localhost/world"
    redis:
      host: 'localhost'
      port: 6379
      db: 2
    qiniu:
      access_key: ''
      secret_key: ''
      bucket: 'sdut'
    mail_options:
      host: "smtp.gmail.com"
      secureConnection: true
      port: 465
      auth:
        user: "lidash156@gmail.com"
        pass: "example.com"
    port: 3000
    domain_name: '127.0.0.1:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    page_size: 10
    site_name: "Demo"
    copyleft: "©2013-2014 Coffee@<a href='http://github.com/lidashuang/coffeecup'>github</a>"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

  test:
    mongo: "mongodb://username:password@hostname:port/db"
    redis:
      host: 'localhost'
      port:6379
      db: 2
    qiniu:
      access_key: ''
      secret_key: ''
      bucket: ''
    mail_options:
      host: "smtp.gmail.com"
      secureConnection: true
      port: 465
      auth:
        user: "lidash156@gmail.com"
        pass: "example.com"
    port: 3000
    domain_name: 'localhost:3000'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "Coffee"
    copyleft: "©2013-2014 Coffee@<a href='http://github.com/lidashuang/coffeecup'>github</a>"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

  production:
    mongo: "mongodb://username:password@hostname:port/db"
    redis:
      host: 'localhost'
      port: 6379
      db: 2
    qiniu:
      access_key: ''
      secret_key: ''
      bucket: 'sdut'
    mail_options:
      host: "smtp.gmail.com"
      secureConnection: true
      port: 465
      auth:
        user: "lidash156@gmail.com"
        pass: "example.com"
    port: 3000
    domain_name: 'node-bbs.ap01.aws.af.cm'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "Pro"
    copyleft: "©2013-2014 Coffee@<a href='http://github.com/lidashuang/coffeecup'>github</a>"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

module.exports =  (env) -> settings[env]
