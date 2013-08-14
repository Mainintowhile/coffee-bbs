settings =
  development:
    site_name: "A2C"

  production:
    site_name: "A2C"

getSettings = (env) ->
  settings[env]

module.exports = getSettings