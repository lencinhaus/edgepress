# an abstract controller class that redirects to home if the user is not authenticated
class @AuthenticatedController extends RouteController
	before: ->
    console.log "auth"
		if not Meteor.loggingIn() and not Meteor.user()
			console.warn "unauthenticated access to route #{Router.current().route.name} is not allowed"
			@redirect "home"

Router.configure
  layoutTemplate: "layout"
  notFoundTemplate: "notFound"
  loadingTemplate: "loading"

Router.map ->
  @route "home", 
  	path: "/"

  @route "dashboardHome",
  	path: "/dashboard" 
  	controller: "DashboardHomeController"

  @route "dashboardBlog", 
  	path: "/dashboard/:slug",
  	controller: "DashboardBlogController"

  @route "dashboardCreatePost",
    path: "dashboard/:blogSlug/post"
    controller: "DashboardPostController"

  @route "dashboardEditPost",
    path: "dashboard/:blogSlug/post/:postSlug"
    controller: "DashboardPostController"