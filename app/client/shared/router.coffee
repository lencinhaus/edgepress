# an abstract controller class that redirects to home if the user is not authenticated
class share.AuthenticatedController extends RouteController
	before: ->
		if not Meteor.loggingIn() and not Meteor.user()
			console.warn "unauthenticated access to route #{Router.current().route.name} is not allowed"
			@redirect "home"

Router.configure
	layoutTemplate: "layout"
	loadingTemplate: "loading"

Router.map ->
  @route "home", 
  	path: "/"

  @route "dashboardHome",
  	path: "/dashboard" 
  	controller: "DashboardHomeController"

  @route "dashboardViewBlog", 
  	path: "/dashboard/:slug",
  	controller: "DashboardViewBlogController"

  @route "dashboardCreatePost",
    path: "dashboard/:slug/post/new"
    controller: "DashboardCreatePostController"