Future = Npm.require "fibers/future"

# utils
maybeWithLatency = (f) ->
	future = new Future

	delayed = ->
		future.return f()

	Meteor.setTimeout delayed, 0

	future.wait()

# startup
Meteor.startup ->
	# clear everything
	# Blogs.remove {}

	# models
	Blogs.allow
		remove: (userId, blog) ->
			blog.userId is userId

# published data
Meteor.publish "userBlogs", ->
	userId = @userId
	maybeWithLatency ->
		Blogs.find 
    	userId: userId

Meteor.publish "userBlogPosts", (blogSlug) ->
	userId = @userId
	maybeWithLatency ->
		blog = Blogs.findOne
			userId: userId
			slug: blogSlug

		if blog 
			Posts.find
				blogId: blog._id
		else 
			null

# matches
NonEmptyString = Match.Where (x) ->
	check x, String
	x.length > 0

# methods
Meteor.methods
	createBlog: (blog) ->
		check @userId, NonEmptyString
		check blog,
			name: NonEmptyString
			slug: Match.Where (slug) ->
				check slug, NonEmptyString
				/^[a-z0-9\-]+$/.test slug

		_.extend blog,
			userId: @userId

		blog._id = Blogs.insert blog

		blog
