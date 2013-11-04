Template.editor.rendered = ->
	# get the height of the textarea
	$textarea = $(@find("##{@data.id}"))
	textareaHeight = $textarea.height()

	# create wysihtml5 editor
	@editor = new wysihtml5.Editor @data.id,
		style: false
		toolbar: @find ".editor-toolbar"
		parserRules: wysihtml5ParserRules

	# get the editor's iframe and style it
	$iframe = $(@find(".wysihtml5-sandbox"))
	$iframe.height textareaHeight

	@editor.on "focus:composer", ->
		$iframe.toggleClass "focused", true

	@editor.on "blur:composer", ->
		$iframe.toggleClass "focused", false