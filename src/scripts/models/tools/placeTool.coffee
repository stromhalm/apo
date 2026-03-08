###
	This tool creates new places in petri nets.
###

class @PlaceTool extends @Tool
	constructor: ->
		super()
		@name = "Places"
		@icon = "radio_button_unchecked"
		@description = "Create places"
		@draggable = true

	clickOnCanvas: (net, point) -> net.addNode(new Place({x: point.x, y: point.y}))
