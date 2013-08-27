exports.requiredLogined = (req, res, next) => 
  if req.session? && req.session.user?
    next()
  else
    if req.xhr
      res.json { success: 0, message: "please_signin" }
    else
      req.flash 'notices', "Please Login"
      res.redirect '/login'
