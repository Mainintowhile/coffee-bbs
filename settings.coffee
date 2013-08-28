settings =
  development:
    db: 'world'
    host: 'localhost'
    port: 3000
    root_url: 'http://localhost:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    page_size: 10
    site_name: "SDUT"
    copyleft: "©2013-2014 SDUT"

  test:
    db: 'world'
    host: 'localhost'
    port: 3000
    root_url: 'http://localhost:3000'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "SDUT"
    copyleft: "©2013-2014 SDUT"

  production:
    db: 'world'
    host: 'localhost'
    port: 3000
    root_url: 'http://localhost:3000'
    page_size: 20
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
    site_name: "SDUT"
    copyleft: "©2013-2014 SDUT"
 
module.exports =  (env) -> settings[env]
