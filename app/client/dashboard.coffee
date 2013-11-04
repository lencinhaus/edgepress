class @DashboardBaseController extends AuthenticatedController
  before: ->
    @subscribe("userBlogs").wait()
    return

  data: ->
    # stop if not ready
    if not @ready() 
      @stop()
      return

    @dataReady()

  dataReady: ->
    blogs: Blogs.find()

  action: ->
    super()
    @render "dashboardLayout"
    return

class @DashboardHomeController extends DashboardBaseController
  # need this otherwise superclass before is called twice
  before: ->
    return

  action: ->
    super()
    @render "dashboardHome", to: "dashboardContent"
    return

class @DashboardBlogController extends DashboardBaseController
  before: ->
    @subscribe("userBlogPosts", @params.slug).wait()
    return
  
  dataReady: ->
    blog = Blogs.findOne 
      slug: @params.slug

    if not blog
      console.warn "blog #{@params.slug} not found"
      @redirect "dashboardHome"
      return

    _.extend super(),
      blog: blog
      posts: Posts.find
        blogId: blog._id

  action: ->
    super()
    @render "dashboardBlog", to: "dashboardContent"
    return

class @DashboardPostController extends DashboardBaseController
  before: ->
    @subscribe("userBlogPosts", @params.blogSlug).wait()

    return

  dataReady: ->
    blog = Blogs.findOne 
      slug: @params.blogSlug

    if not blog
      console.warn "blog #{@params.blogSlug} not found"
      @redirect "dashboardHome"
      return

    post = null

    if @params.postSlug
      post = Posts.findOne
        blogId: blog._id
        slug: @params.postSlug

      if not post
        console.warn "post #{@params.postSlug} not found"
        @redirect "dashboardBlog",
          slug: blog.slug
        return
    
    _.extend super(),
      blog: blog
      post: post
        
  action: ->
    super()
    @render "dashboardPost", to: "dashboardContent"
    return

Template.dashboardLayout.isCurrentBlog = (blog) ->
  blog and blog._id is @_id

Template.dashboardLayout.haveBlogs = ->
  @blogs and @blogs.count()

Template.dashboardLayout.created = ->
  # need to remember if we added the jquery callbacks, otherwise they will be re-added on each render
  @addedJQueryCallbacks = false

Template.dashboardLayout.rendered = ->
  if not @addedJQueryCallbacks
    @addedJQueryCallbacks = true
    @slugChanged = false
    self = this

    $("#modal-create-blog").on "show.bs.modal", ->
      # form validation
      parsleyOptions = getBaseParsleyOptions()
      
      _.extend parsleyOptions.messages,
        regexp: parsleyOptions.messages.slug

      _.extend parsleyOptions,
        validators:
          unique: (val, enabled, self) ->
            if not enabled then return true
            not Blogs.findOne(slug: val)?

      $("#form-create-blog").parsley parsleyOptions

    $("#modal-create-blog").on "shown.bs.modal", ->
      $('#input-new-blog-name').focus()

    $("#modal-create-blog").on "hidden.bs.modal", ->
      $("#form-create-blog").parsley "destroy"

    $("#input-new-blog-name").keyup ->
      if self.slugChanged then return
      $("#input-new-blog-slug").val createSlug @value

    $("#input-new-blog-slug").keyup ->
      self.slugChanged = true

Template.dashboardLayout.events
  "keyup #form-create-blog input[type=text]": (evt) ->
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

    Meteor.call "createBlog", blog, (error, blogId) ->
      if error
        console.error error
        FlashMessages.sendError __ "common.errors.server"

        # resume deps
        Deps.resume()
        return

      # once the modal is hidden
      $("#modal-create-blog").one "hidden.bs.modal", ->
        # resume deps
        Deps.resume()

        # add a flash message
        FlashMessages.sendSuccess __ "dashboard.createBlogForm.successFlash", 
          name: name

        #reset create blog form
        $("#input-new-blog-name").val ""
        $("#input-new-blog-slug").val ""

        # view the blog
        Router.go "dashboardBlog",
          slug: blog.slug

      # close the create blog modal
      $("#modal-create-blog").modal "hide"

Template.dashboardBlog.created = ->
  # need to remember if we added the jquery callbacks, otherwise they will be re-added on each render
  @addedJQueryCallbacks = false

Template.dashboardBlog.rendered = ->
  if not @addedJQueryCallbacks
    @addedJQueryCallbacks = true
    self = this
    
    $("#modal-edit-blog").on "shown.bs.modal", ->
      $('#input-edit-blog-name').focus()

    $("#modal-edit-blog").on "show.bs.modal", ->
      # form validation
      parsleyOptions = getBaseParsleyOptions()
      
      _.extend parsleyOptions.messages,
        regexp: parsleyOptions.messages.slug

      _.extend parsleyOptions,
        validators:
          unique: (val, enabled) ->
            if not enabled then return true
            not Blogs.findOne
              slug: val,
              _id:
                $ne: self.data.blog._id
      
      $("#form-edit-blog").parsley parsleyOptions

    $("#modal-edit-blog").on "hidden.bs.modal", ->
      $("#form-edit-blog").parsley "destroy"

Template.dashboardBlog.pathForCreatePost = ->
  Router.path "dashboardCreatePost",
    blogSlug: @slug

Template.dashboardBlog.pathForEditPost = ->
  blog = Blogs.findOne
    _id: @blogId
  Router.path "dashboardEditPost",
    blogSlug: blog?.slug
    postSlug: @slug

Template.dashboardBlog.events
  "keyup #form-edit-blog input[type=text]": (evt) ->
    if evt.which is 13
      $("#button-update-blog").click()

  "click #button-update-blog": ->
    # validate the form
    if not $("#form-edit-blog").parsley "validate"
      return

    # pause deps until the modal is hidden
    Deps.pause()

    # save the new blog
    blog = @blog
    blog.name = $("#input-edit-blog-name").val() 
    blog.slug = $("#input-edit-blog-slug").val()

    Meteor.call "editBlog", blog, (error, affected) ->
      if error or not affected
        console.error error
        FlashMessages.sendError __ "common.errors.server"

        # resume deps
        Deps.resume()
        return

      # once the modal is hidden
      $("#modal-edit-blog").one "hidden.bs.modal", ->
        # resume deps
        Deps.resume()

        # view the blog
        Router.go "dashboardBlog",
          slug: blog.slug

        # add a flash message
        FlashMessages.sendSuccess __ "dashboard.editBlogForm.successFlash", 
          name: blog.name

      # close the create blog modal
      $("#modal-edit-blog").modal "hide"

  "click #button-delete-blog-confirm": ->
    # pause deps until the modal is hidden
    Deps.pause()

    blog = @blog

    # delete the current blog
    Blogs.remove blog._id, (error) ->
      if error
        console.error error
        FlashMessages.sendError __ "common.errors.server"

        # resume deps
        Deps.resume()
        return

      # add a flash message
      FlashMessages.sendSuccess __("dashboard.deleteBlogModal.successFlash", blog)

      # when the modal is hidden
      $('#modal-delete-blog').one "hidden.bs.modal", ->
        # go home lassie
        Router.go "dashboardHome"

        # resume deps
        Deps.resume()

      # close the modal
      $("#modal-delete-blog").modal "hide"

Template.dashboardPost.created = ->
  # need to remember if we added the jquery callbacks, otherwise they will be re-added on each render
  @addedJQueryCallbacks = false

Template.dashboardPost.rendered = ->
  self = this
  # if existing post, focus on content
  if @data.post
    $("#editor-post-content").focus()
  # otherwise, focus on title
  else 
    $("#input-post-title").focus()

  if not @addedJQueryCallbacks
    @addedJQueryCallbacks = true

    # form validation
    parsleyOptions = getBaseParsleyOptions()
    
    _.extend parsleyOptions.messages,
      regexp: parsleyOptions.messages.slug

    _.extend parsleyOptions,
      validators:
        unique: (val, enabled) ->
          if not enabled then return true
          selector = 
            slug: val
          if self.data.post
            _.extend selector,
              _id:
                $ne: self.data.post._id
          not Posts.findOne selector

    $("#form-post").parsley parsleyOptions
    return

Template.dashboardPost.destroyed = ->
  $("#form-post").parsley "destroy"
    
Template.dashboardPost.editorData = ->
  id: 'editor-post-content'
  class: 'form-control'
  placeholder: __ "dashboard.postForm.contentPlaceholder"
  value: @post?.content

Template.dashboardPost.events
  "click #button-save-post": ->
    # validate the form
    if not $("#form-post").parsley "validate"
      return

    console.log "valid"
    isNew = not @post
    post = if isNew then {} else @post
    blog = @blog
    _.extend post,
      blogId: @blog._id
      title: $("#input-post-title").val()
      slug: $("#input-post-slug").val()
      content: $("#editor-post-content").val()
    console.log post

    Meteor.call "savePost", post, (error, postId) ->
      if error
        console.error error
        FlashMessages.sendError __ "common.errors.server"

        return

      # add a flash message
      message = if isNew then "dashboard.newPost.successFlash" else "dashboard.editPost.successFlash"
      FlashMessages.sendSuccess __ message, post

      # go to post editing
      Router.go "dashboardEditPost",
        blogSlug: blog.slug
        postSlug: post.slug