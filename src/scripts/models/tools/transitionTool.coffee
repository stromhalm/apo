class @TransitionTool extends @Tool
	constructor: ->
		@name = "Transitions"
		@icon = "check_box_outline_blank"

	mouseDownOnCanvas: (net, point) -> net.addTransition(point)
