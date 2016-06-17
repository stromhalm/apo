class Editor extends Controller

	constructor: ($timeout, $scope, $state, $stateParams, NetStorage) ->

		net = NetStorage.getNetByName(decodeURI($stateParams.name))
		# Go to first net if not found
		if not net
			$state.go "editor", name: NetStorage.getNets()[0].name
			return
		$scope.net = net

		svg = d3.select('#main-canvas svg')
		force = d3.layout.force()
		colors = d3.scale.category10()
		drag_line = svg.select('svg .dragline')
		edges = svg.append('svg:g').selectAll('path')
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
			edges
			.style('marker-start', (edge) -> if edge.left then 'url(#startArrow)' else '')
			.style('marker-end', (edge) -> if edge.right then 'url(#endArrow)' else '')

			# add new links
			edges.enter().append('svg:path').attr('class', 'link')
				.style('marker-start', (edge) -> if edge.left then 'url(#startArrow)' else '')
				.style('marker-end', (edge) -> if edge.right then 'url(#endArrow)' else '')
				.on 'mousedown', (edge) ->
					# select link
					mouseDownEdge = edge
					selectedNode = null
					restart()

			# remove old links
			edges.exit().remove()

			nodes = nodes.data(net.nodes, (node) -> node.id)

			# update existing nodes
			nodes.selectAll('.node')
			.classed('reflexive', (node) -> node.reflexive)

			# add new nodes
			newNodes = nodes.enter().append('svg:g')
			newNodes.append((node) -> document.createElementNS("http://www.w3.org/2000/svg", NetStorage.getNodeFromData(node).shape))
			.attr('class', (node) -> NetStorage.getNodeFromData(node).type + ' node')
			.attr('r', (node) -> NetStorage.getNodeFromData(node).radius)
			.attr('width', (node) -> NetStorage.getNodeFromData(node).width)
			.attr('height', (node) -> NetStorage.getNodeFromData(node).height)
			.on 'mouseover', (node) ->
				return if !mouseDownNode or node == mouseDownNode
				d3.select(this).attr('transform', 'scale(1.1)') # enlarge target node

			.on 'mouseout', (node) ->
				return if !mouseDownNode or node == mouseDownNode
				d3.select(this).attr 'transform', '' # unenlarge target node

			.on 'mousedown', (node) ->
				# select node
				mouseDownNode = node
				if mouseDownNode == selectedNode
					selectedNode = null
				else
					selectedNode = mouseDownNode

				# reposition drag line
				drag_line.style('marker-end', 'url(#endArrow)').classed('hidden', false).attr('d', 'M' + mouseDownNode.x + ',' + mouseDownNode.y + 'L' + mouseDownNode.x + ',' + mouseDownNode.y)
				restart()

			.on 'mouseup', (node) ->
				mouseUpNode = node
				return if not mouseDownNode

				drag_line.classed('hidden', true).style('marker-end', '') # needed by FF

				# check for drag-to-self
				if mouseUpNode == mouseDownNode
					resetMouseVars()
					return

				# unenlarge target node
				d3.select(this).attr 'transform', ''

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
					edge[direction] = true
				else
					if net.isConnectable(source, target)
						edge = new Edge({source: source, target: target})
						edge[direction] = true
						net.addEdge(edge)
						$scope.$apply() # Quick save net to storage

				# select new link
				selectedNode = null
				restart()

			# show node text
			newNodes.append('svg:text').attr('x', 0).attr('y', 4).attr('class', 'label').text((node) -> NetStorage.getNodeFromData(node).getText())

			nodes.exit().remove() # remove old nodes
			force.start() # set the graph in motion

		mousedown = ->
			svg.classed 'active', true
			return if mouseDownNode or mouseDownEdge

			# fire the current tool's mouseDown listener
			point = new Point(d3.mouse(this)[0], d3.mouse(this)[1])
			net.getActiveTool().mouseDownOnCanvas(net, point)
			$scope.$apply() # Quick save net to storage
			restart()

		mousemove = ->
			return if not mouseDownNode

			# update drag line
			drag_line.attr('d', 'M' + mouseDownNode.x + ',' + mouseDownNode.y + 'L' + d3.mouse(this)[0] + ',' + d3.mouse(this)[1])
			restart()

		mouseup = ->
			drag_line.classed('hidden', true).style('marker-end', '') if mouseDownNode # hide drag line
			svg.classed('active', false)
			resetMouseVars()

		# init D3 force layout
		force = force.nodes(net.nodes).links(net.edges).size([
			if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
			window.innerHeight + 80
		])
		.linkDistance(150)
		.charge(-500)
		.on('tick', tick)

		# fix lost references to nodes
		for edge in net.edges
			edge.source = net.nodes.filter((node) -> node.id == edge.source.id)[0]
			edge.target = net.nodes.filter((node) -> node.id == edge.target.id)[0]

		# motion starts here
		svg.on('mousedown', mousedown).on('mousemove', mousemove).on 'mouseup', mouseup
		restart()
