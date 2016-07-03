class @PlaceTool extends @Tool
	constructor: ->
		@name = "Places"
		@icon = "radio_button_unchecked"

	mouseDownOnCanvas: (net, point) ->
		net.addPlace(point)
