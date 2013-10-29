@createSlug = (name) ->
	if not name or name.length == 0 then null

	# lowercase
	name = name.toLowerCase()

	# remove anything except letters, numbers and separators
	name = name.replace /[^a-z0-9\-_ ]/g, ""

	# replace all separators with dashes
	name = name.replace /[ _]/g, "-"

	# remove dashes at beginning and end
	name = name.replace /^\-+/, ""
	name = name.replace /\-+$/, ""

	# compact dashes and return
	name.replace /\-\-+/g, "-"