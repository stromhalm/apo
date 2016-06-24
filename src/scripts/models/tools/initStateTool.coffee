class @InitStateTool extends @Tool
	constructor: ->
		@name = "Initial State"
		@icon = "play_for_work"

	mouseDownOnNode: (net, node) ->
		net.setInitState(node)
