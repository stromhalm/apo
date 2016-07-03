class @StateTool extends @Tool
	constructor: ->
		@name = "States"
		@icon = "radio_button_unchecked"

	mouseDownOnCanvas: (net, point) -> net.addState(point)
