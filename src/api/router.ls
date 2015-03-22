require! {
	express
}

routing =
	account:
		[\post /\/account\/create(\..+)?$/ './rest/account/create']
		[\get /\/account\/show(\..+)?$/ './rest/account/show']
		[\put /\/account\/update(\..+)?$/ './rest/account/update']
		[\put /\/account\/update_icon(\..+)?$/ './rest/account/update_icon']
		[\put /\/account\/update_header(\..+)?$/ './rest/account/update_header']
		[\put /\/account\/update_wallpaper(\..+)?$/ './rest/account/update_wallpaper']
		[\put /\/account\/update_webtheme(\..+)?$/ './rest/account/update_webtheme']
		[\get /\/account\/unreadalltalks_count(\..+)?$/ './rest/account/unreadalltalks_count']
		[\delete /\/account\/reset_webtheme(\..+)?$/ './rest/account/reset_webtheme']

exports = (app) ->
	app
		..all '*' (req, res, next) ->
			filename = req.url.match /.+\/(.+?)([\?#;].*)?$/
			if filename?
				extension = filename.1.match /\.(.+)$/
				req.format = extension.1 if extension != null
			next!
		
		# Authorize
		..get    '/authorize' require './authorize-get'
		..post   '/authorize' (req, res) -> (require './authorize-post') req, res, app
		..get    /\/sauth\/get_request_token(\..+)?$/      require './rest/sauth/get_request_token'
	
	routing.account |> each ([method, url, handler]) ->
		app[method] url, require handler
	
	app
		# Application
		..post   /\/application\/create(\..+)?$/           require './rest/application/create'
		..post   /\/application\/delete(\..+)?$/           require './rest/application/delete'
		
		# Notice
		..delete /\/notice\/delete(\..+)?$/                require './rest/notice/delete'
		..delete /\/notice\/deleteall(\..+)?$/             require './rest/notice/deleteall'
		
		# Users
		..get    /\/users\/show(\..+)?$/                   require './rest/users/show'
		..post   /\/users\/follow(\..+)?$/                 require './rest/users/follow'
		..delete /\/users\/unfollow(\..+)?$/               require './rest/users/unfollow'
		
		# Status
		..post   /\/status\/update(\..+)?$/                require './rest/status/update'
		..post   /\/status\/favorite(\..+)?$/              require './rest/status/favorite'
		..post   /\/status\/repost(\..+)?$/                require './rest/status/repost'
		..get    /\/status\/timeline(\..+)?$/              require './rest/status/timeline'
		
		# Talk
		..post   /\/talk\/say(\..+)?$/                     require './rest/talk/say'
		..put    /\/talk\/fix(\..+)?$/                     require './rest/talk/fix'
		..delete /\/talk\/delete(\..+)?$/                  require './rest/talk/delete'
		..post   /\/talk\/read(\..+)?$/                    require './rest/talk/read'
		
		# Circle
		..post   /\/circle\/create(\..+)?$/                require './rest/circle/create'
		..get    /\/circle\/show(\..+)?$/                  require './rest/circle/show'
		..put    /\/circle\/update(\..+)?$/                require './rest/circle/update'
		
		# Other
		..get    /\/search\/user(\..+)?$/                  require './rest/search/user'
		..get    /\/screenname_available(\..+)?$/          require './rest/screenname_available'
		..all    /\/teapot\/coffee(\..+)?$/                require './rest/teapot/coffee'
