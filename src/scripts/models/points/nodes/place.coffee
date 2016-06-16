class @Place extends @Node
	constructor: (point) ->
		@type = "place"
		super(point)

	getText: -> "s#{@id}"
