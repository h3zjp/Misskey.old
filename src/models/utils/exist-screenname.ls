require! {
	'../user': User
}

# String -> Promise Boolean
module.exports = (screen-name) ->
	resolve, reject <- new Promise!
	
	err, exist <- User
		.find {screen-name}
		.limit 1
		.exec
		
	if err?
		then reject err
		else resolve exist != []
