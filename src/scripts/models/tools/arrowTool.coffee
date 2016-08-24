###
	This tool is active in all nets.
	It is used to draw directed edges between nodes.
###

class @ArrowTool extends @Tool
	constructor: ->
		super()
		@name = "Arrows"
		@icon = "keyboard_backspace"
		@description = "Connect nodes in the graph via arrows"

	mouseDownOnNode: (net, node, dragLine) ->
		dragLine.style('marker-end', 'url(#endArrow)').classed('hidden', false).attr('d', 'M' + node.x + ',' + node.y + 'L' + node.x + ',' + node.y)

	mouseUpOnNode: (net, mouseUpNode, mouseDownNode, dragLine) ->

		return if not mouseDownNode
		dragLine.classed('hidden', true).style('marker-end', '') # needed by FF

		# check for drag-to-self
		if mouseUpNode == mouseDownNode
			return

		for edge in net.edges when edge.source is mouseDownNode and edge.target is mouseUpNode
			existingEdge = edge
		if existingEdge
			existingEdge.right = 1
		else
			for edge in net.edges when edge.source is mouseUpNode and edge.target is mouseDownNode
				existingEdge = edge
		if existingEdge
			existingEdge.left = 1
		else
			if net.isConnectable(mouseDownNode, mouseUpNode)
				if net.type is "pn"
					edge = new PnEdge({source: mouseDownNode, target: mouseUpNode, right: 1})
				else
					edge = new TsEdge({source: mouseDownNode, target: mouseUpNode, right: 1})
				net.addEdge(edge)
