class @Place extends @Node
	constructor: (point) ->
		@type = "place"
		@connectableTypes = ["transition"]
		super(point)

	getText: -> "s#{@id}"
