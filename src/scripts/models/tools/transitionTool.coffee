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

	clickOnCanvas: (net, point) -> net.addNode(new Transition({x: point.x, y: point.y}))
