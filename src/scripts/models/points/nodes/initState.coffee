###
	Attention: This is a hidden node, that connects the real init state by the (visible) TsInitEdge
###

class @InitState extends @Node
	constructor: (point) ->
		super(point)
		@type = "initState"
		@radius = 0

	getText: -> ""
