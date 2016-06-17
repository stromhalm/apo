###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class @Net
	constructor: (netObject) ->
		{@name, @nodes = [], @edges = [], @tools = []} = netObject

	setTools: (@tools) ->
		@activeTool = @tools[0].name if not @activeTool and @tools.length > 0

	addEdge: (edge) -> @edges.push(edge)

	addNode: (node) ->
		node.setId(@nodes.length)
		@nodes.push(node)

	getActiveTool: ->
		for tool in @tools
			if tool.name is @activeTool
				return tool
