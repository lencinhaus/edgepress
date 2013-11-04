@Blogs = new Meteor.Collection "blogs"
@Blogs.allow
	insert: ->
		# use method
		false

	update: ->
		# use method
		false

	remove: (userId, doc) ->
		# only the owner
		userId and doc.userId is userId

	fetch: ["userId"]

@Posts = new Meteor.Collection "posts"
@Posts.allow
	insert: ->
		# use method
		false

	update: ->
		# use method
		false

	remove: (userId, doc) ->
		# only the blog owner
		if not userId then false
		blog = Blogs.findOne
			_id: doc.blogId
		blog and blog.userId is userId

	fetch: ["blogId"]