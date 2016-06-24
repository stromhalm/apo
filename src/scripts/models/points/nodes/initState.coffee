class @InitState extends @Node
	constructor: (point) ->
		super(point)
		@type = "initState"
		@reflexive = false

	getText: -> ""
