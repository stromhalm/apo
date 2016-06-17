class @StateTool extends @Tool
	constructor: ->
		@name = "State"
		@icon = "radio_button_unchecked"

	mouseDownOnCanvas: (net, point) -> net.addState(point)
