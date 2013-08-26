settings =
  development:
    site_name: "shanliren"

  test:
    site_name: "shanliren"

  production:
    site_name: "shanliren"

getSettings = (env) ->
  settings[env]

module.exports = getSettings
