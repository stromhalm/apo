class @Tool
	constructor: ->
		@icon = "help_outline"
		@draggable = false

	# ngStorage can't save circle references.
	# Therefore we can't save the net reference – is has to be passed with every function call

	mouseDownOnNode: (net, node, dragLine) ->

	mouseUpOnNode: (net, mouseUpNode, mouseDownNode, dragLine) ->

	mouseDownOnEdge: (net, edge) ->

	mouseDownOnCanvas: (net, point, dragLine) ->

	dblClickOnNode: (net, node) ->
