
# GET /search
exports.index = (req, res) ->
  search = req.query.q
  domain = req.headers.host
  res.redirect "https://www.google.com.hk/#hl=zh-CN&q=site:#{domain}+#{search}"
