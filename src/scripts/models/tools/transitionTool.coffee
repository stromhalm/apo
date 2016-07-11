class @TransitionTool extends @Tool
	constructor: ->
		super()
		@name = "Transitions"
		@icon = "check_box_outline_blank"
		@draggable = true

	mouseDownOnCanvas: (net, point) -> net.addTransition(point)
