class @Transition extends @Node
	constructor: (point) ->
		super(point)
		@type = "transition"
		@reflexive = false
