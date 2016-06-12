###
	The Net is an abstract model for both petri nets and transition systems.
	It consists of nodes and edges.
###

class NetFactory extends Factory
	constructor: ->
		return Net


class Net
	constructor: (netObject) ->
		@name = netObject.name
		@nodes = netObject.nodes
		@edges = netObject.edges

		@addNode = (point) ->
			node =
				id: @nodes.length
				reflexive: false
				x: point[0]
				y: point[1]
			@nodes.push(node)
