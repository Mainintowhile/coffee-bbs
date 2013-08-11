exports.index = (req, res) ->
  res.render "index",
    title: "topics index page"

exports.show = (req, res) ->
	res.render "show", 
		title : "show page"