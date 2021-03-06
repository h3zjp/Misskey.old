#
# Misskey Web streaming server
#

require! {
	fs
	http
	cookie
	redis
	'../config'
	'./web-streaming/home'
	'./web-streaming/mobile-home'
	'./web-streaming/talk'
	'./web-streaming/bbs-thread'
	'./web-streaming/log'
	'express-session': session
	'socket.io': SocketIO
}

console.log 'Web-streaming server loaded'

read-file = (path) -> fs.read-file-sync path .to-string!

server = http.create-server (req, res) ->
	res
		..write-head 200 'Content-Type': 'text/plain'
		..end 'kyoppie'

io = SocketIO.listen server

RedisStore = (require \connect-redis) session
session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

# Authorization
io.use (socket, next) ->
	raw-cookie = socket?request?headers?cookie
	if cookie
		parsed-cookie = cookie.parse raw-cookie
		is-authorized = parsed-cookie[config.session-key] != /s:(.+?)\./
		if is-authorized
		then next new Error '[[error:not-authorized]]'
		else next!

# Home stream
home io, session-store

# Mobile Home stream
mobile-home io, session-store

# Talk stream
talk io, session-store

# BBS Thread stream
bbs-thread io, session-store

# Misskey log stream
log io

server.listen config.port.web-streaming
