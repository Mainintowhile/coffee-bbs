exports.requiredLogined = (req, res, next) => 
  if req.session? && req.session.user?
    next()
  else
    req.flash 'notices', "Please Login"
    res.redirect '/login'
