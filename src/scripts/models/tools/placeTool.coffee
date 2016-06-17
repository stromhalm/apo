class @PlaceTool extends @Tool
	constructor: ->
		@name = "Place"
		@icon = "radio_button_unchecked"

	mouseDownOnCanvas: (net, point) ->
		net.addPlace(point)
