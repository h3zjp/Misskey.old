require! {
	express
	compression
	'express-minify'
}

create-server = ->
	server = express!
	server.disable 'x-powered-by'
	server.use compression!
	server.use express-minify!
	server

module.exports = create-server
