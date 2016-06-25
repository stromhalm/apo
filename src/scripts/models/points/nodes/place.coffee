class @Place extends @Node
	constructor: (point) ->
		{@token = 0} = point
		super(point)
		@type = "place"
		@connectableTypes = ["transition"]
		@labelYoffset = 30

	getText: ->
		return @label if @label
		return "s#{@id}"

	getTokenLabel: ->
		return "" if @token is 0
		return @token
