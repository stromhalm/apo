###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class @Net
	constructor: (netObject) ->
		@name = netObject.name
		@nodes = netObject.nodes
		@edges = netObject.edges

	addNode: (node) ->
		node.setId(@nodes.length)
		@nodes.push(node)
