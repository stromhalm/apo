class Editor extends Controller

	constructor: ($timeout, $scope, $state, $stateParams, NetStorage, $mdDialog, converterService) ->

		net = NetStorage.getNetByName(decodeURI($stateParams.name))
		# Go to first net if not found
		if not net
			$state.go "editor", name: NetStorage.getNets()[0].name
			return
		$scope.net = net

		svg = d3.select('#main-canvas svg')
		force = d3.layout.force()
		drag = force.drag()
		colors = d3.scale.category10()
		dragLine = svg.select('svg .dragline')
		edges = svg.append('svg:g').selectAll('.edge')
		nodes = svg.append('svg:g').selectAll('g')

		# mouse event vars
		selectedNode = null
		mouseDownEdge = null
		mouseDownNode = null
		mouseUpNode = null

		resetMouseVars = ->
			mouseDownNode = null
			mouseUpNode = null
			mouseDownEdge = null

		# Adjust SVG canvas on window resize
		resize = ->
			width = if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
			height = window.innerHeight
			svg.attr('width', width).attr 'height', height
			force.size([
				width
				height + 80
			]).resume()
		resize()
		d3.select(window).on 'resize', resize

		# update net positions (called each iteration)
		tick = ->
			# draw directed edges with proper padding from node centers
			edges.attr 'd', (edge) ->
				edge = new Edge(edge)
				edge.getPath()
			nodes.attr 'transform', (d) ->
				'translate(' + d.x + ',' + d.y + ')'

		# update graph layout (called when needed)
		restart = ->
			edges = edges.data(net.edges)

			# update existing links
			edges.style('marker-start', (edge) -> if edge.left > 0 then 'url(#startArrow)' else '')
			edges.style('marker-end', (edge) -> if edge.right > 0 then 'url(#endArrow)' else '')

			# update existing edge labels
			d3.selectAll('.edgeLabel .text').text((edge) -> converterService.getEdgeFromData(edge).getText())

			# add edge labels
			edges.enter().append('svg:text').attr('dy', -8).attr('class', 'label edgeLabel')
			.attr('id', (edge) -> 'edgeLabel-' + edge.id)
			.append('textPath').attr('startOffset', '50%').attr('class', 'text')
			.attr('xlink:href', (edge) -> '#' + edge.id).text((edge) -> converterService.getEdgeFromData(edge).getText())

			# add egde paths
			edges.enter().append('svg:path').attr('class', 'link')
				.style('marker-start', (edge) -> if edge.left > 0 then 'url(#startArrow)' else '')
				.style('marker-end', (edge) -> if edge.right > 0 then 'url(#endArrow)' else '')
				.attr('id', (edge) -> edge.id)
				.classed('edge', true)
				.on 'mousedown', (edge) ->
					mouseDownEdge = edge
					selectedNode = null

					# call the tools mouseDown listener
					net.getActiveTool().mouseDownOnEdge(net, mouseDownEdge, $mdDialog, restart, converterService)
					$scope.$apply() # Quick save net to storage
					restart()

			# remove old links
			edges.exit().each((edge) -> d3.selectAll('#edgeLabel-' + edge.id).remove()).remove()

			nodes = nodes.data(net.nodes, (node) -> node.id)

			# update existing nodes
			nodes.selectAll('.node').classed('firable', (node) ->  net.isFirable(node))

			# update existing node labels
			d3.selectAll('.nodeLabel').text((node) -> converterService.getNodeFromData(node).getText())
			d3.selectAll('.token').text((node) -> converterService.getNodeFromData(node).getTokenLabel())

			# add new nodes
			newNodes = nodes.enter().append('svg:g')
			newNodes.append((node) -> document.createElementNS("http://www.w3.org/2000/svg", converterService.getNodeFromData(node).shape))
			.attr('class', (node) -> node.type + ' node')
			.attr('r', (node) -> node.radius)
			.attr('width', (node) -> node.width)
			.attr('height', (node) -> node.height)
			.classed('firable', (node) ->  net.isFirable(node))
			.on 'mouseover', (node) ->
				return if !mouseDownNode or node == mouseDownNode or !net.isConnectable(mouseDownNode, node)
				d3.select(this).style('fill', 'rgb(235, 235, 235)') # highlight target node

			.on 'mouseout', (node) ->
				return if !mouseDownNode or node == mouseDownNode
				d3.select(this).attr 'style', '' # unhighlight target node

			.on 'mousedown', (node) ->

				nodes.call(drag) if net.getActiveTool().draggable # drag and drop

				# select node
				mouseDownNode = node
				if mouseDownNode == selectedNode
					selectedNode = null
				else
					selectedNode = mouseDownNode

				# call the tools mouseDown listener
				net.getActiveTool().mouseDownOnNode(net, mouseDownNode, dragLine, $mdDialog, restart)
				$scope.$apply() # Quick save net to storage
				restart()

			.on 'mouseup', (node) ->
				mouseUpNode = node

				d3.select(this).style('fill', '') # unhighlight target node
				net.getActiveTool().mouseUpOnNode(net, mouseUpNode, mouseDownNode, dragLine)
				$scope.$apply() # Quick save net to storage

				nodes.on('mousedown.drag', null)

				selectedNode = null
				restart()

			.on 'dblclick', (node) ->
				net.getActiveTool().dblClickOnNode(net, node)


			# show node text
			newNodes.append('svg:text').attr('x', (node) -> node.labelXoffset).attr('y', (node) -> node.labelYoffset).attr('class', 'label nodeLabel').text((node) -> converterService.getNodeFromData(node).getText())
			newNodes.append('svg:text').attr('x', 0).attr('y', 4).attr('class', 'label token').text((node) -> converterService.getNodeFromData(node).getTokenLabel())

			nodes.exit().remove() # remove old nodes
			force.start() # set the graph in motion

		mousedown = ->
			svg.classed 'active', true
			return if mouseDownNode or mouseDownEdge

			# fire the current tool's mouseDown listener
			point = new Point({x: d3.mouse(this)[0], y: d3.mouse(this)[1]})
			net.getActiveTool().mouseDownOnCanvas(net, point)
			$scope.$apply() # Quick save net to storage
			restart()

		mousemove = ->
			return if not mouseDownNode

			# update drag line
			dragLine.attr('d', 'M' + mouseDownNode.x + ',' + mouseDownNode.y + 'L' + d3.mouse(this)[0] + ',' + d3.mouse(this)[1])
			restart()

		mouseup = ->
			dragLine.classed('hidden', true).style('marker-end', '') if mouseDownNode # hide drag line
			svg.classed('active', false)
			resetMouseVars()

		# init D3 force layout
		force = force.nodes(net.nodes).links(net.edges).size([
			if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
			window.innerHeight + 80
		])
		.linkDistance((edge) -> edge.length)
		.charge(-500)
		.on('tick', tick)

		# fix lost references to nodes
		for edge in net.edges
			edge.source = net.nodes.filter((node) -> node.id == edge.source.id)[0]
			edge.target = net.nodes.filter((node) -> node.id == edge.target.id)[0]

		# motion starts here
		svg.on('mousedown', mousedown).on('mousemove', mousemove).on 'mouseup', mouseup
		restart()
