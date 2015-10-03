class ItemController
	->
		THIS = @

		################################
		# Init UI
		@$controller = $ \#item-controller
		@$controller-item-title = @$controller.find \.title
		@$controller-pos-back-button = @$controller.find \.pos-back-button
		@$controller-pos-forward-button = @$controller.find \.pos-forward-button
		@$controller-pos-left-button = @$controller.find \.pos-left-button
		@$controller-pos-right-button = @$controller.find \.pos-right-button
		@$controller-pos-up-button = @$controller.find \.pos-up-button
		@$controller-pos-down-button = @$controller.find \.pos-down-button
		@$controller-pos-x-input = @$controller.find \.pos-x
		@$controller-pos-y-input = @$controller.find \.pos-y
		@$controller-pos-z-input = @$controller.find \.pos-z
		@$controller-rotate-x-input = @$controller.find \.rotate-x
		@$controller-rotate-y-input = @$controller.find \.rotate-y
		@$controller-rotate-z-input = @$controller.find \.rotate-z

		$ \html .keydown (e) ->
			switch (e.which)
			| 39 => # Key[→]
				if e.shift-key
					THIS.change-pos-z THIS.item.position.z - 0.01
				else
					THIS.change-pos-z THIS.item.position.z - 0.1
			| 37 => # Key[←]
				if e.shift-key
					THIS.change-pos-z THIS.item.position.z + 0.01
				else
					THIS.change-pos-z THIS.item.position.z + 0.1
			| 38 => # Key[↑]
				if e.shift-key
					THIS.change-pos-x THIS.item.position.x - 0.01
				else
					THIS.change-pos-x THIS.item.position.x - 0.1
			| 40 => # Key[↓]
				if e.shift-key
					THIS.change-pos-x THIS.item.position.x + 0.01
				else
					THIS.change-pos-x THIS.item.position.x + 0.1

		@$controller-pos-back-button.click ->
			THIS.change-pos-x THIS.item.position.x + 0.1

		@$controller-pos-forward-button.click ->
			THIS.change-pos-x THIS.item.position.x - 0.1

		@$controller-pos-left-button.click ->
			THIS.change-pos-z THIS.item.position.z + 0.1

		@$controller-pos-right-button.click ->
			THIS.change-pos-z THIS.item.position.z - 0.1

		@$controller-pos-up-button.click ->
			THIS.change-pos-y THIS.item.position.y + 0.1

		@$controller-pos-down-button.click ->
			THIS.change-pos-y THIS.item.position.y - 0.1

		@$controller-pos-x-input.bind \input ->
			THIS.change-pos-x THIS.$controller-pos-x-input.val!

		@$controller-pos-y-input.bind \input ->
			THIS.change-pos-y THIS.$controller-pos-y-input.val!

		@$controller-pos-z-input.bind \input ->
			THIS.change-pos-z THIS.$controller-pos-z-input.val!

		@$controller-rotate-x-input.bind \input ->
			THIS.change-rotate-x THIS.$controller-rotate-x-input.val!

		@$controller-rotate-y-input.bind \input ->
			THIS.change-rotate-y THIS.$controller-rotate-y-input.val!

		@$controller-rotate-z-input.bind \input ->
			THIS.change-rotate-z THIS.$controller-rotate-z-input.val!

		################################
		# Init viewer
		canvas = document.get-element-by-id \item-controller-preview-canvas
		width = canvas.width
		height = canvas.height

		# Scene settings
		@scene = new THREE.Scene!

		# Renderer settings
		@renderer = new THREE.WebGLRenderer {canvas, +antialias, +alpha}
			..set-pixel-ratio window.device-pixel-ratio
			..set-size width, height
			..set-clear-color 0x000000 0
			..auto-clear = off
			..shadow-map.enabled = on
			..shadow-map.cull-face = THREE.CullFaceBack

		# Camera settings
		@camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 100
			..zoom = 10
			..position.x = 0
			..position.y = 2
			..position.z = 0
			..update-projection-matrix!
		@scene.add @camera

		# AmbientLight
		ambient-light = new THREE.AmbientLight 0xffffff 1
			..cast-shadow = no
		@scene.add ambient-light

		# PointLight
		light = new THREE.PointLight 0xffffff 1 100
		light.position.set 3 3 3
		@scene.add light

		#@scene.add new THREE.AxisHelper 5
		grid = new THREE.GridHelper 5 0.5
			..set-colors 0x444444 0x444444
		@scene.add grid

		@render!

	render: ->
		timer = Date.now! * 0.0004

		# SEE:
		# http://stackoverflow.com/questions/22039180/failed-to-execute-requestanimationframe-on-window-the-callback-provided-as
		# http://stackoverflow.com/questions/6065169/requestanimationframe-with-this-keyword
		# https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Function/bind
		request-animation-frame @render.bind @

		if @item?
			item-height = @item-bounding-box.size!.y

			@camera.position.y = 2 + (item-height / 2)
			@camera.position.z = (Math.cos timer) * 10
			@camera.position.x = (Math.sin timer) * 10
			@camera.look-at new THREE.Vector3 0, (item-height / 2), 0

			@renderer.render @scene, @camera

	update:	(item) ->
		@item = item
		if item?
			@$controller.css \display \block
			@$controller-item-title.text item.room-item-info.obj.name
			@$controller-pos-x-input.val item.position.x
			@$controller-pos-y-input.val item.position.y
			@$controller-pos-z-input.val item.position.z
			@$controller-rotate-x-input.val item.rotation.x
			@$controller-rotate-y-input.val item.rotation.y
			@$controller-rotate-z-input.val item.rotation.z

			# Remove old object
			old = @scene.get-object-by-name \obj
			if old?
				@scene.remove old

			# Add new object
			preview-obj = item.clone!
				..name = \obj
				..position.x = 0
				..position.y = 0
				..position.z = 0
				..rotation.x = 0
				..rotation.y = 0
				..rotation.z = 0

			preview-obj.traverse (child) ->
				if child instanceof THREE.Mesh
					child.material = child.material.clone!
					child.material.emissive.set-hex 0x000000

			@item-bounding-box = new THREE.Box3!.set-from-object preview-obj
			@scene.add preview-obj
		else
			@$controller.css \display \none

	change-pos-x: (x) ->
		x = Number x
		if x > 2.5 then x = 2.5
		if x < -2.5 then x = -2.5
		@item.position.x = x
		@$controller-pos-x-input.val x

	change-pos-y: (y) ->
		y = Number y
		if y > 1.5 then y = 1.5
		if y < 0 then y = 0
		@item.position.y = y
		@$controller-pos-y-input.val y

	change-pos-z: (z) ->
		z = Number z
		if z > 2.5 then z = 2.5
		if z < -2.5 then z = -2.5
		@item.position.z = z
		@$controller-pos-z-input.val z

	change-rotate-x: (x) ->
		x = Number x
		@item.rotation.x = x
		@$controller-rotate-x-input.val x

	change-rotate-y: (y) ->
		y = Number y
		@item.rotation.y = y
		@$controller-rotate-y-input.val y

	change-rotate-z: (z) ->
		z = Number z
		@item.rotation.z = z
		@$controller-rotate-z-input.val z

class Room
	(item-controller) ->
		THIS = @

		shadow-quolity = 8192
		debug = no

		@item-controller = item-controller
		@room-items = JSON.parse ($ \html .attr \data-room-items)

		@active-items = []
		@unactive-items = []

		width = window.inner-width
		height = window.inner-height

		################################
		# Init scene

		# Scene settings
		@scene = new THREE.Scene!

		# Renderer settings
		@renderer = new THREE.WebGLRenderer {-antialias}
			..set-pixel-ratio window.device-pixel-ratio
			..set-size width, height
			..auto-clear = off
			..set-clear-color new THREE.Color 0x051f2d
			..shadow-map.enabled = on
			#..shadow-map-soft = off
			#..shadow-map-cull-front-faces = on
			..shadow-map.cull-face = THREE.CullFaceBack
		#document.get-element-by-id \main .append-child renderer.dom-element
		document.body.append-child @renderer.dom-element

		# Camera settings
		#camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 1000
		@camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, -10, 10
			..zoom = 100
			..position.x = 2
			..position.y = 2
			..position.z = 2
			..update-projection-matrix!
		@scene.add @camera

		# AmbientLight
		ambient-light = new THREE.AmbientLight 0xffffff 1
			..cast-shadow = no
		@scene.add ambient-light

		# Room light (for shadow)
		room-light = new THREE.SpotLight 0xffffff 0.2
			..position.set 0 8 0
			..cast-shadow = on
			..shadow-map-width = shadow-quolity
			..shadow-map-height = shadow-quolity
			..shadow-camera-near = 0.1
			..shadow-camera-far = 9
			..shadow-camera-fov = 45
			#..only-shadow = on
			#..shadow-camera-visible = on #debug
		#@scene.add room-light

		out-light = new THREE.SpotLight 0xffffff 0.4
			..position.set 9 3 -2
			..cast-shadow = on
			..shadow-bias = -0.001 # アクネ、アーチファクト対策 その代わりピーターパンが発生する可能性がある
			..shadow-map-width = shadow-quolity
			..shadow-map-height = shadow-quolity
			..shadow-camera-near = 6
			..shadow-camera-far = 15
			..shadow-camera-fov = 45
			..shadow-camera-visible = debug
			#..only-shadow = on
		@scene.add out-light

		# Controller setting
		@controls = new THREE.OrbitControls @camera, @renderer.dom-element
			..target.set 0 1 0
			..enable-zoom = debug
			..enable-pan = debug
			..min-polar-angle = 0
			..max-polar-angle = if debug then Math.PI else Math.PI / 2
			..min-azimuth-angle = 0
			..max-azimuth-angle = if debug then Math.PI else Math.PI / 2

		# DEBUG
		if debug
			@scene.add new THREE.AxisHelper 10
			@scene.add new THREE.GridHelper 5 1

		################################
		# POST FXs

		render-target = new THREE.WebGLRenderTarget width, height, {
			min-filter: THREE.LinearFilter
			mag-filter: THREE.LinearFilter
			format: THREE.RGBFormat
			-stencil-buffer
		}

		fxaa = new THREE.ShaderPass THREE.FXAAShader
			..uniforms['resolution'].value = new THREE.Vector2 (1 / width), (1 / height)

		to-screen = new THREE.ShaderPass THREE.CopyShader
			..render-to-screen = on

		@composer = new THREE.EffectComposer @renderer, render-target
			..add-pass new THREE.RenderPass @scene, @camera
			..add-pass new THREE.BloomPass 0.5 25 128.0 512
			..add-pass fxaa
			..add-pass to-screen

		################################

		# Hover highlight
		@renderer.dom-element.onmousemove = (e) ->
			rect = e.target.get-bounding-client-rect!
			x = ((e.client-x - rect.left) / THIS.renderer.dom-element.width) * 2 - 1
			y = -((e.client-y - rect.top) / THIS.renderer.dom-element.height) * 2 + 1
			pos = new THREE.Vector2 x, y
			THIS.camera.update-matrix-world!
			raycaster = new THREE.Raycaster!
			raycaster.set-from-camera pos, THIS.camera
			intersects = raycaster.intersect-objects THIS.active-items, on

			THIS.active-items.for-each (item) ->
				item.traverse (child) ->
					if child instanceof THREE.Mesh
						if (not child.is-active?) or (not child.is-active)
							child.material.emissive.set-hex 0x000000

			if intersects.length > 0
				INTERSECTED = intersects[0].object.source
				INTERSECTED.traverse (child) ->
					if child instanceof THREE.Mesh
						if (not child.is-active?) or (not child.is-active)
							child.material.emissive.set-hex 0x191919

		@renderer.dom-element.onmousedown = (e) ->
			if (e.target == THIS.renderer.dom-element) and (e.button == 2)
				rect = e.target.get-bounding-client-rect!
				x = ((e.client-x - rect.left) / THIS.renderer.dom-element.width) * 2 - 1
				y = -((e.client-y - rect.top) / THIS.renderer.dom-element.height) * 2 + 1
				pos = new THREE.Vector2 x, y
				THIS.camera.update-matrix-world!
				raycaster = new THREE.Raycaster!
				raycaster.set-from-camera pos, THIS.camera
				intersects = raycaster.intersect-objects THIS.active-items, on

				THIS.selected-item = null
				THIS.item-controller.update null

				THIS.active-items.for-each (item) ->
					item.traverse (child) ->
						if child instanceof THREE.Mesh
							child.material.emissive.set-hex 0x000000
							child.is-active = no

				if intersects.length > 0
					INTERSECTED = intersects[0].object.source
					THIS.selected-item = INTERSECTED

					# Highlight
					INTERSECTED.traverse (child) ->
						if child instanceof THREE.Mesh
							child.material.emissive.set-hex 0xff0000
							child.is-active = yes

					THIS.item-controller.update THIS.selected-item

		################################
		# Load items of room
		loader = new THREE.OBJMTLLoader!
		loader.load '/resources/common/3d-models/room/room.obj' '/resources/common/3d-models/room/room.mtl' (object) ->
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.receive-shadow = on
					child.cast-shadow = on
			object.position.set 0 0 0
			@scene.add object

		@room-items.for-each (item) ->
			if item.position?
				load-item item, (object) ->
					THIS.scene.add object
					THIS.active-items.push object
			else
				$item = $ "<li><p class='name'>#{item.obj.name}</p></li>"
				$set-button = $ "<button>置く</button>"
					..click ->
						load-item item, (object) ->
							THIS.scene.add object
							THIS.active-items.push object
				$item.append $set-button
				$ \#box .find \ul .append $item
				THIS.unactive-items.push item

		@render!

	render: ->
		#timer = Date.now! * 0.0004
		request-animation-frame @render.bind @
		#out-light.position.z = (Math.cos timer) * 10
		#out-light.position.x = (Math.sin timer) * 10
		@controls.update!
		@renderer.clear!
		@composer.render!
		#renderer.render scene, camera

function load-item(item, cb)
	switch (item.obj.model-type)
	| \json =>
		loader = new THREE.ObjectLoader!
		loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.json" (object) ->
			object.position.x = if item.position? and item.position.x? then item.position.x else 0
			object.position.y = if item.position? and item.position.y? then item.position.y else 0
			object.position.z = if item.position? and item.position.z? then item.position.z else 0
			object.rotation.x = if item.rotation? and item.rotation.x? then item.rotation.x else 0
			object.rotation.y = if item.rotation? and item.rotation.y? then item.rotation.y else 0
			object.rotation.z = if item.rotation? and item.rotation.z? then item.rotation.z else 0
			object.cast-shadow = on
			object.receive-shadow = on
			object.name = item.individual-id
			cb object
	| \objmtl =>
		loader = new THREE.OBJMTLLoader!
		loader.load "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.obj" "/resources/common/3d-models/#{item.obj.id}/#{item.obj.id}.mtl" (object) ->
			object.position.x = if item.position? and item.position.x? then item.position.x else 0
			object.position.y = if item.position? and item.position.y? then item.position.y else 0
			object.position.z = if item.position? and item.position.z? then item.position.z else 0
			object.rotation.x = if item.rotation? and item.rotation.x? then item.rotation.x else 0
			object.rotation.y = if item.rotation? and item.rotation.y? then item.rotation.y else 0
			object.rotation.z = if item.rotation? and item.rotation.z? then item.rotation.z else 0
			object.name = item.individual-id
			object.room-item-info = item
			object.traverse (child) ->
				if child instanceof THREE.Mesh
					child.source = object
					child.cast-shadow = on
					child.receive-shadow = on
			cb object

################################################################

item-controller = new ItemController
room = new Room item-controller
