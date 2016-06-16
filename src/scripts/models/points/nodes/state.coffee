class @State extends @Node
	constructor: (node) ->
		@type = "state"
		@reflexive = false
		super(node)
