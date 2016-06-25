class @State extends @Node
	constructor: (point) ->
		@type = "state"
		@connectableTypes = ["state"]
		super(point)
