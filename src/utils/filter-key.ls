# [String] -> Object -> Object
module.exports = (allowed, obj) -->
	obj |> obj-to-pairs |> filter ([key, ]) -> key in (camelize allowed) |> pairs-to-obj
