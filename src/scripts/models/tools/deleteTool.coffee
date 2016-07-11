class @DeleteTool extends @Tool
	constructor: ->
		super()
		@name = "Delete"
		@icon = "delete"

	mouseDownOnNode: (net, node) -> net.deleteNode(node)

	mouseDownOnEdge: (net, edge) -> net.deleteEdge(edge)
