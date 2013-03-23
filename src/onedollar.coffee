class window.OneDollar

	constructor: (@fragmentation=64, @size=250, @angle=45, @step=3) ->
		
		# final/constants
		@PI = Math.PI
		@HALFDIAGONAL = 0.5*Math.sqrt(@size*@size+@size*@size)

		# learned gestures
		@templates = {}

	learn: (name, points) ->
		@templates[name] = points