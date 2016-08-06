class @DeleteTool extends @Tool
	constructor: ->
		super()
		@name = "Delete"
		@icon = "delete"
		@description = "Delete nodes and arrows in the graph"

	mouseDownOnNode: (net, node) -> net.deleteNode(node)

	mouseDownOnEdge: (net, edge) -> net.deleteEdge(edge)
