class @InitStateTool extends @Tool
	constructor: ->
		super()
		@name = "Initial State"
		@icon = "play_for_work"
		@description = "Set a state as initial state"

	mouseDownOnNode: (net, node) -> net.setInitState(node)
