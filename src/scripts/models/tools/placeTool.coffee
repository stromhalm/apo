class @PlaceTool extends @Tool
	constructor: ->
		super()
		@name = "Places"
		@icon = "radio_button_unchecked"
		@draggable = true

	mouseDownOnCanvas: (net, point) ->
		net.addPlace(point)
