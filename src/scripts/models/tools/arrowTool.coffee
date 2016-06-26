class @ArrowTool extends @Tool
	constructor: ->
		@name = "Arrow"
		@icon = "keyboard_backspace"

	mouseDownOnNode: (net, node, dragLine) ->
		dragLine.style('marker-end', 'url(#endArrow)').classed('hidden', false).attr('d', 'M' + node.x + ',' + node.y + 'L' + node.x + ',' + node.y)

	mouseUpOnNode: (net, mouseUpNode, mouseDownNode, dragLine) ->

		return if not mouseDownNode
		dragLine.classed('hidden', true).style('marker-end', '') # needed by FF

		# check for drag-to-self
		if mouseUpNode == mouseDownNode
			resetMouseVars()
			return

		# add link to graph (update if exists)
		if mouseDownNode.id < mouseUpNode.id
			source = mouseDownNode
			target = mouseUpNode
			direction = 'right'
		else
			source = mouseUpNode
			target = mouseDownNode
			direction = 'left'
		edge = net.edges.filter((edge) -> edge.source == source and edge.target == target)[0]
		if edge
			edge[direction] = 1
		else
			if net.isConnectable(source, target)
				if net.type is "pn"
					edge = new PnEdge({source: source, target: target})
				else edge = new TsEdge({source: source, target: target})
				edge[direction] = 1
				net.addEdge(edge)
				
