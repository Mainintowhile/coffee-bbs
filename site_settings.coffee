settings =
  development:
    site_name: "SDUT"
    copyleft: "©2013-2014 SDUT"

  test:
    site_name: "SDUT"
    copyleft: "©2012-2013 SDUT"

  production:
    site_name: "SDUT"
    copyleft: "©2012-2013 SDUT"

getSettings = (env) ->
  settings[env]

module.exports = getSettings
