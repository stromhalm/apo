###
	The node class is used as an abstract class for states, places and transitions
###

class @Node extends @Point
	constructor: (options = false) ->
		super(options)
		{@id = false, @label = ""} = options
		@shape = 'circle'
		@radius = 18
		@labelXoffset = 0
		@labelYoffset = 4
		@connectableTypes = []

	getText: ->
		return @label if @label
		return @id

	getTokenLabel: -> ""

	getSelfEdgePath: -> ""

	getSelfEdgeText: -> ""
