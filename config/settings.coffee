settings =
  development:
    mongo:
      db: 'world'
      host: 'localhost'
    redis:
      host: 'localhost'
      port: 6379
      db: 2
    port: 3000
    domain_name: 'localhost:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    page_size: 10
    site_name: "Demo"
    copyleft: "©2013-2014 Coffee"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

  test:
    mongo:
      db: 'world'
      host: 'localhost'
    redis:
      host: 'localhost'
      port: 6379
      db: 2
    port: 3000
    domain_name: 'localhost:3000'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "Coffee"
    copyleft: "©2013-2014 Coffee"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

  production:
    mongo:
      db: 'world'
      host: 'localhost'
    redis:
      host: 'localhost'
      port: 6379
      db: 2
    port: 3000
    domain_name: 'node-bbs.ap01.aws.af.cm'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "Coffee"
    copyleft: "©2013-2014 Coffee"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."
 
module.exports =  (env) -> settings[env]
