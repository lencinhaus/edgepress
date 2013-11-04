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

# patterns
NonEmptyString = Match.Where (x) ->
  check x, String
  x.length > 0
slugRegExp = /^[a-z0-9\-]+$/
ValidBlog = (userId) ->
  # if an id is sent, it must exist
  _id: Match.Optional Match.Where (id) ->
    !!Blogs.find(
      _id: id
      userId: userId
    ).count()
  # non-empty name
  name: NonEmptyString
  # non-empty, valid slug
  slug: Match.Where (slug) ->
    check slug, NonEmptyString
    slugRegExp.test slug

# published data
Meteor.publish "userBlogs", ->
  userId = @userId
  maybeWithLatency ->
    Blogs.find 
      userId: userId

Meteor.publish "userBlogPosts", (blogSlug) ->
  check blogSlug, NonEmptyString
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

# methods
Meteor.methods
  createBlog: (blog) ->
    check @userId, NonEmptyString
    check blog, ValidBlog @userId

    # the slug shouldn't exist
    userId = @userId
    check blog.slug, Match.Where (slug) ->
      not Blogs.find(
        slug: slug
        userId: userId
      ).count()

    _.extend blog,
      userId: @userId

    Blogs.insert blog

  editBlog: (blog) ->
    check @userId, NonEmptyString
    check blog, Match.ObjectIncluding ValidBlog @userId
    check blog._id, String

    # the slug shouldn't be the same as another blog
    userId = @userId
    check blog.slug, Match.Where (slug) ->
      not Blogs.find(
        _id:
          $ne: blog._id
        slug: slug
        userId: userId
      ).count()

    Blogs.update blog._id, 
      $set: _.pick blog, "name", "slug"

  savePost: (post) ->
    userId = @userId

    # check common required fields
    check post, Match.ObjectIncluding
      title: NonEmptyString
      slug: Match.Where (slug) ->
        check slug, NonEmptyString
        slugRegExp.test slug
      content: String

    if post._id isnt undefined
      # existing post
      # keep allowed properties
      postId = post._id
      post = _.pick post, "title", "slug", "content"
      # the post must exist and be part of a blog owned by the current user
      existing = null
      check postId, Match.Where (id) ->
        check id, NonEmptyString
        existing = Posts.findOne
          _id: id
        existing and !!Blogs.find(
          _id: existing.blogId
          userId: userId
        ).count()
      # the slug must be unique in the blog or same as before
      check post.slug, Match.Where (slug) ->
        not Posts.find(
          _id: 
            $ne: postId
          slug: post.slug
          blogId: existing.blogId
        ).count()
      # update the post
      Posts.update postId,
        $set: post
    else
      # new post
      # keep allowed properties
      post = _.pick post, "blogId", "title", "slug", "content"
      # the post must be part of an existing blog owned by the current user
      check post.blogId, Match.Where (blogId) ->
        check blogId, NonEmptyString
        !!Blogs.find(
          _id: blogId
          userId: userId
        ).count()
      # the slug must be unique in the blog
      check post.slug, Match.Where (slug) ->
        not Posts.find(
          slug: post.slug
          blogId: post.blogId
        ).count()
      # insert the post
      Posts.insert post
