settings =
  development:
    site_name: "HEL-Hello World"

  test:
    site_name: "HEL-Hello World"

  production:
    site_name: "HEL-Hello World"

getSettings = (env) ->
  settings[env]

module.exports = getSettings
