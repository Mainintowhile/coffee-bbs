settings =
  development:
    db: 'world'
    host: 'localhost'
    port: 3000
    root_url: 'http://localhost:3000'
    domain_name: 'localhost:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    page_size: 10
    site_name: "Coffee"
    copyleft: "©2013-2014 Coffee"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

  test:
    db: 'world'
    host: 'localhost'
    port: 3000
    root_url: 'http://localhost:3000'
    domain_name: 'localhost:3000'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "Coffee"
    copyleft: "©2013-2014 Coffee"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."

  production:
    db: 'world'
    host: 'localhost'
    port: 3000
    root_url: 'http://localhost:3000'
    domain_name: 'localhost:3000'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "Coffee"
    copyleft: "©2013-2014 Coffee"
    about: "Ember.js is a JavaScript framework that does all of the heavy lifting that you'd normally have to do by hand. There are tasks that are common to every web app; Ember.js does those things for you, so you can focus on building killer features and UI."
 
module.exports =  (env) -> settings[env]
