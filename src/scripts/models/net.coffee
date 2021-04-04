###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class @Net
	constructor: (netObject) ->
		{@name, @nodes = [], @edges = [], @tools = [], @analyzers = [], @activeTool = false} = netObject

	setActiveTool: (tool) -> @activeTool = tool.name

	addEdge: (edge) ->
		edge.id = @getMaxEdgeId()+1
		@edges.push(edge)
		edge

	deleteEdge: (deleteEdge) -> @edges = (edge for edge in @edges when edge isnt deleteEdge)

	addNode: (node) ->
		node.id = @getMaxNodeId()+1
		@nodes.push(node)
		node

	deleteNode: (deleteNode) ->
		# Delete connected edges
		@edges = (edge for edge in @edges when edge.source isnt deleteNode and edge.target isnt deleteNode)

		#delete node
		@nodes = (node for node in @nodes when node isnt deleteNode)

	getActiveTool: ->
		return tool for tool in @tools when tool.name is @activeTool
		if @tools.length > 0 then @tools[0] else false

	getPreset: (node) ->
		preset = []
		for edge in @edges
			if (edge.target is node and edge.right >= 1)
				preset.push(edge.source)
			else if (edge.source is node and edge.left >= 1)
				preset.push(edge.target)
		return preset

	getPostset: (node) ->
		preset = []
		for edge in @edges
			if (edge.target is node and edge.left >= 1)
				preset.push(edge.source)
			else if (edge.source is node and edge.right >= 1)
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
