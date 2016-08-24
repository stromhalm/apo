###
	This tool creates new transitions in petri nets.
###

class @TransitionTool extends @Tool
	constructor: ->
		super()
		@name = "Transitions"
		@icon = "check_box_outline_blank"
		@description = "Create transitions"
		@draggable = true

	mouseDownOnCanvas: (net, point) -> net.addTransition(point)
