blogId = null

Meteor.startup ->
  # create a blog if it doesn't exist
  blog = Blogs.findOne
  if blog
    blogId = Blogs.insert
      name: "Blog"
  else blogId = blog._id

# publish data
Meteor.publish "posts", ->
  Posts.find
    blogId: blogId
    
Meteor.publish "latestPosts", ->
  Posts.find {}, 
    sort:
      modifiedDate: -1
    limit: 10