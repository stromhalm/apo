class @MoveTool extends @Tool
	constructor: ->
		super()
		@name = "Fix Nodes"
		@icon = "gps_fixed"
		@description = "Move nodes to fix their position. Double click to free them."
		@draggable = true

	mouseDownOnNode: (net, node) ->
		node.fixed = true

	dblClickOnNode: (net, node) ->
		node.fixed = false
