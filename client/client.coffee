Meteor.subscribe "posts"
Meteor.subscribe "latestPosts"
  
Handlebars.registerHelper "isCurrentRoute", (name) ->
  Router.current()?.route?.name is name or false
    
Router.configure
  layout: "layout"