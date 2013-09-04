env = process.env.NODE_ENV or 'development'
settings = require("../../config/settings")(env)

# GET /search
exports.index = (req, res) ->
  search = req.query.q
  domain = settings.domain_name
  res.redirect "https://www.google.com.hk/#hl=zh-CN&q=site:#{domain}+#{search}"
