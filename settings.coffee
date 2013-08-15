settings =
  development:
    db: 'world'
    host: 'localhost'
    root_url: 'http://localhost:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'

  test:
    db: 'world'
    host: 'localhost'
    root_url: 'http://localhost:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'

  production:
    db: 'world'
    host: 'localhost'
    root_url: 'http://localhost:3000'
    cookieSecret: "hello world"
    root: 'ldshuang@gmail.com'
 

getSettings = (env) ->
  settings[env]

module.exports = getSettings
