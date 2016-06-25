class @Place extends @Node
	constructor: (point) ->
		@type = "place"
		@connectableTypes = ["transition"]
		super(point)

	getText: ->
		return @label if @label
		return "s#{@id}"
