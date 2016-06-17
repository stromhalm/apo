class @Tool
	constructor: (options) ->
		@icon = 'help_outline'
		@netName = ''

	# ngStorage can't save circle references.
	# Therefore we can't save the net reference

	clickOnNode: (net, node) ->

	clickOnEdge: (net, edge) ->

	mouseDownOnCanvas: (net, point) ->
