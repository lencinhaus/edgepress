var blogId = null;

Meteor.startup(function() {
    // create a blog if it doesn't exist
    var blog = Blogs.findOne();
    if(!blog) {
        blogId = Blogs.insert({
            name: "Blog"
        });
    } else blogId = blog._id;
});

// publish data
Meteor.publish("posts", function() {
    return Posts.find({
        blogId: blogId
    });
});