class @State extends @Node
	constructor: (options) ->
		super(options)
		@type = "state"
		@connectableTypes = ["state"]
		{@labelsToSelf = []} = options
		@radius = 18

	getSelfEdgeText: -> @labelsToSelf.join(", ")

	getSelfEdgePath: -> "M 0,-#{@radius} C 0,-#{@radius*5} #{@radius*5},0 #{@radius+5},0"
