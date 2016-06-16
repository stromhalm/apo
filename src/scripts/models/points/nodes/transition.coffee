class @Transition extends @Node
	constructor: (point) ->
		super(point)
		@type = "transition"
		@reflexive = false
		@shape = "rect"
		@width = 35
		@height = 35

	getText: -> "t#{@id}"
