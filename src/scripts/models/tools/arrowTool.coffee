class @ArrowTool extends @Tool
	constructor: ->
		@name = "Arrows"
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

		existingEdge = edge for edge in net.edges when edge.source is mouseDownNode and edge.target is mouseUpNode
		if existingEdge
			existingEdge.right = 1
		else
			existingEdge = edge for edge in net.edges when edge.source is mouseUpNode and edge.target is mouseDownNode
		if existingEdge
			existingEdge.left = 1
		else
			if net.isConnectable(mouseDownNode, mouseUpNode)
				if net.type is "pn"
					edge = new PnEdge({source: mouseDownNode, target: mouseUpNode, right: 1})
				else
					edge = new TsEdge({source: mouseDownNode, target: mouseUpNode, right: 1})
				net.addEdge(edge)
