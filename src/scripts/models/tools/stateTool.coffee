###
	This tool creates new states in transition systems.
###

class @StateTool extends @Tool
	constructor: ->
		super()
		@name = "States"
		@icon = "radio_button_unchecked"
		@description = "Create states"
		@draggable = true

	mouseDownOnCanvas: (net, point) -> net.addState(point)
