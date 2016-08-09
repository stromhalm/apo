###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class @Net
	constructor: (netObject) ->
		{@name, @nodes = [], @edges = [], @tools = []} = netObject

	setTools: (@tools) ->
		@activeTool = @tools[0].name if not @activeTool and @tools.length > 0

	setAnalyzers: (@analyzers) ->

	addEdge: (edge) ->
		edge.setId(@getMaxEdgeId()+1)
		@edges.push(edge)

	deleteEdge: (deleteEdge) ->
		for edge, id in @edges when edge.id is deleteEdge.id
			@edges.splice(id, 1)
			return true
		return false

	addNode: (node) ->
		node.setId(@getMaxNodeId()+1)
		@nodes.push(node)

	deleteNode: (deleteNode) ->
		# Delete connected edges
		oldEdges = []
		for edge in @edges
			if (edge.source.id is deleteNode.id) or (edge.target.id is deleteNode.id)
				if oldEdges.indexOf(edge) is -1
					oldEdges.push(edge)
		for edge in oldEdges
			@deleteEdge(edge)

		#delete node
		for node, index in @nodes when node.id is deleteNode.id
			@nodes.splice(index, 1)
			return true
		return false

	getActiveTool: ->	return tool for tool in @tools when tool.name is @activeTool

	getPreset: (node) ->
		preset = []
		for edge in @edges
			if (edge.target.id is node.id and edge.right >= 1)
				preset.push(edge.source)
			else if (edge.source.id is node.id and edge.left >= 1)
				preset.push(edge.target)
		return preset

	getPostset: (node) ->
		preset = []
		for edge in @edges
			if (edge.target.id is node.id and edge.left >= 1)
				preset.push(edge.source)
			else if (edge.source.id is node.id and edge.right >= 1)
				preset.push(edge.target)
		return preset

	isConnectable: (source, target) ->
		source.connectableTypes.indexOf(target.type) isnt -1

	getNodeByText: (text) ->
		return node for node in @nodes when node.getText() is text
		return false

	getMaxNodeId: ->
		maxId = -1
		for node in @nodes when (node.id > maxId)
			maxId = node.id
		maxId

	getMaxEdgeId: ->
		maxId = -1
		for edge in @edges when (edge.id > maxId)
			maxId = edge.id
		maxId

	isFirable: (node) -> false
