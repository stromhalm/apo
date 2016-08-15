class @InitState extends @Node
	constructor: (point) ->
		super(point)
		@type = "initState"
		@radius = 0

	getText: -> ""
