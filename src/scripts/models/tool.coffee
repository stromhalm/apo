class @Tool
	constructor: (options) ->
		@icon = "help_outline"
		@netName = ""

	# ngStorage can't save circle references.
	# Therefore we can't save the net reference

	mouseDownOnNode: (net, node) ->

	mouseUpOnNode: (net, mouseUpNode, mouseDownNode, dragLine) ->

	mouseDownOnEdge: (net, edge) ->

	mouseDownOnCanvas: (net, point, dragLine = null) ->
