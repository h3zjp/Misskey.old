require! {
	'../../../../../models/user': User
	'../../../../../models/user-room': UserRoom
	'../../../../../config'
	'../../../../../room-items.json'
}

module.exports = (req, res, options) ->
	user = options.user
	me = if req.login then req.me else null
		
	err, room <- UserRoom.find-one {user-id: user.id}

	if room?
		display room
	else
		room = new UserRoom!
			..user-id = user.id
			..items =
				{
					individual-id: \a
					item-id: \bed
					position:
						x: 1.95
						y: 0
						z: -1.4
					rotation:
						x: 0
						y: 3.141592653589793
						z: 0
				}
				{
					individual-id: \b
					item-id: \carpet
					position:
						x: 0
						y: 0
						z: 0
					rotation:
						x: 0
						y: 0
						z: 0
				}
				{
					individual-id: \c
					item-id: \mat
					position:
						x: -2.2
						y: 0
						z: 0.4
					rotation:
						x: 0
						y: 0
						z: 0
				}
				{
					individual-id: \d
					item-id: \cardboard-box
					position:
						x: -2.2
						y: 0
						z: 1.9
					rotation:
						x: 0
						y: 0
						z: 0
				}
				{
					individual-id: \e
					item-id: \milk
					position: null
					rotation: null
				}
				{
					individual-id: \f
					item-id: \facial-tissue
					position: null
					rotation: null
				}
		
		room.save ->
			display room
	
	function display(room)
		room .= to-object!
		Promise.all (room.items |> map (item) ->
			resolve, reject <- new Promise!
			item.obj = (room-items.filter (room-item, index) ->
				room-item.id == item.item-id).0
			resolve item)
		.then (serialized-items) ->
			room.items = serialized-items
			res.display req, res, \user-room {
				user
				room
			}