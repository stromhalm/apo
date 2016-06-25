class @Transition extends @Node
	constructor: (point) ->
		super(point)
		@type = "transition"
		@connectableTypes = ["place"]
		@shape = "rect"
		@width = 35
		@height = 35

	getText: ->
		return @label if @label
		return "t#{@id}"
