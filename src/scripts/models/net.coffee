###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class @Net
	constructor: (netObject) ->
		{@name, @nodes, @edges} = netObject
		@tools = []

	addTool: (tool) ->
		@tools.push(tool)
		@activeTool = @tools[0].name if not @activeTool

	addEdge: (edge) -> @edges.push(edge)

	addNode: (node) ->
		node.setId(@nodes.length)
		@nodes.push(node)
