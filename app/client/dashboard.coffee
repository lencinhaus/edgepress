class DashboardController extends share.AuthenticatedController
	waitOn: ->
		Meteor.subscribe "userBlogs"

	data: ->
		blogs: Blogs.find()

	action: ->
		@render "dashboardLayout"

class @DashboardHomeController extends DashboardController
	action: ->
		super()
		@render "dashboardHome", to: "dashboardContent"

class @DashboardViewBlogController extends DashboardController
	waitOn: ->
		superSubs = super()
		[Meteor.subscribe "userBlogPosts", @params.slug].concat superSubs
	
	data: ->
		blog = Blogs.findOne 
			slug: @params.slug

		if not blog
			console.warn "blog #{@params.slug} not found"
			@redirect "dashboardHome"
		else
			_.extend super(), 
				blog: blog
				posts: Posts.find
					blogId: blog._id

	action: ->
		super()
		@render "dashboardViewBlog", to: "dashboardContent"

Template.dashboardLayout.isCurrentBlog = (blog) ->
	blog and blog._id is @_id

Template.dashboardLayout.haveBlogs = ->
	@blogs and @blogs.count()

Template.dashboardLayout.created = ->
	console.log "created"
	# need to remember if we added the jquery callbacks, otherwise they will be re-added on each render
	@addedJQueryCallbacks = false

Template.dashboardLayout.rendered = ->
	console.log "rendered"
	if not @addedJQueryCallbacks
		console.log "adding jquery"
		@addedJQueryCallbacks = true
		@slugChanged = false
		self = this
		$("#modal-create-blog").on "shown.bs.modal", ->
			$('#input-new-blog-name').focus()

		$("#form-create-blog").parsley
			successClass: "has-success"
			errorClass: "has-error"
			validators:
				slug: (val, enabled, self) ->
					if not enabled then return true
					not Blogs.findOne(slug: val)?
			messages:
				slug: "must be unique"
			errors:
				classHandler: (el) ->
					$(el).closest ".form-group"
				errorsWrapper: "<span class=\"help-block\"></span>"
				errorElem: "<span></span>"

		$("#input-new-blog-name").keyup ->
			if self.slugChanged then return
			$("#input-new-blog-slug").val createSlug @value

		$("#input-new-blog-slug").keyup ->
			self.slugChanged = true


Template.dashboardLayout.events
	"keyup #input-new-blog-name": (evt) ->
		if evt.which is 13
			$("#button-save-blog").click()

	"click #button-save-blog": ->
		# validate the form
		if not $("#form-create-blog").parsley "validate"
			return

		# pause deps until the modal is hidden
		Deps.pause()

		# save the new blog
		name = $("#input-new-blog-name").val() 

		blog = 
			name: name
			slug: $("#input-new-blog-slug").val()

		Meteor.call "createBlog", blog, (error, blog) ->
			if error
				console.error error
				FlashMessages.sendError "Invalid data"

				# resume deps
				Deps.resume()
				return

			# once the modal is hidden
			$("#modal-create-blog").one "hidden.bs.modal", ->
				# resume deps
				Deps.resume()

				# add a flash message
				FlashMessages.sendSuccess "blog #{name} created successfully"

				#reset create blog form
				$("#input-new-blog-name").val ""
				$("#input-new-blog-slug").val ""

				# view the blog
				Router.go "dashboardViewBlog",
					slug: blog.slug

			# close the create blog modal
			$("#modal-create-blog").modal "hide"

Template.dashboardViewBlog.events
	"click #button-update-blog": ->
		# update the blog
		blog = 
			name: $("#input-edit-blog-name").val()

		Blogs.update @blog._id, 
			$set: blog

		# close the modal
		$("#modal-edit-blog").modal "hide"

	"click #button-delete-blog-confirm": ->
		# pause deps until the modal is hidden
		Deps.pause()

		blog = @blog

		# delete the current blog
		Blogs.remove blog._id, (error) ->
			if error
				console.error error
				FlashMessages.sendError "cannot delete blog"

				# resume deps
				Deps.resume()
				return

			# add a flash message
			FlashMessages.sendSuccess "Blog #{blog.name} deleted successfully"

			# when the modal is hidden
			$('#modal-delete-blog').one "hidden.bs.modal", ->
				# go home lassie
				Router.go "dashboardHome"

				# resume deps
				Deps.resume()

			# close the modal
			$("#modal-delete-blog").modal "hide"