class @StateTool extends @Tool
	constructor: ->
		super()
		@name = "States"
		@icon = "radio_button_unchecked"
		@draggable = true

	mouseDownOnCanvas: (net, point) -> net.addState(point)
