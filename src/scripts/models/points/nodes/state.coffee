class @State extends @Node
	constructor: (point) ->
		@type = "state"
		@reflexive = false
		@connectableTypes = ["state"]
		super(point)
