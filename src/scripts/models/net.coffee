###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class @Net
	constructor: (netObject) ->
		{@name, @nodes, @edges} = netObject

	addNode: (node) ->
		node.setId(@nodes.length)
		@nodes.push(node)

	addEdge: (edge) ->
		@edges.push(edge)
