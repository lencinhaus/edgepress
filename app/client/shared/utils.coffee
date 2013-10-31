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

if typeof String::startsWith isnt 'function'
  String::startsWith = (str) ->
    @slice(0, str.length) == str
 
if typeof String::endsWith isnt 'function'
  String::endsWith = (str) ->
    @slice(-str.length) == str

@getBaseParsleyOptions = ->
	options = 
		successClass: "has-success"
		errorClass: "has-error"
		messages: {}
		errors:
			classHandler: (el) ->
				$(el).closest ".form-group"
			errorsWrapper: "<div class=\"help-block\"></div>"
			errorElem: "<div></div>"

	for own key of Meteor.i18nMessages.common.validation
		options.messages[key] = __ "common.validation." + key

	options