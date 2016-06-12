class Editor extends Controller

	constructor: ($scope, $stateParams, $timeout, $state, NetStorage, Net) ->

		# Get selected net from storage
		net = new Net(NetStorage.getNetByName(decodeURI($stateParams.name)))
		$scope.name = net.name
		# Go to first net if not found
		if !net
			$state.go 'editor', name: NetStorage.getNets()[0].current.name

		svg = d3.select('#main-canvas svg')
		force = d3.layout.force()
		colors = d3.scale.category10()
		drag_line = svg.select('svg .dragline')
		allPathes = svg.append('svg:g').selectAll('path')
		allCircles = svg.append('svg:g').selectAll('g')
		# mouse event vars
		selected_node = null
		selected_link = null
		mousedown_link = null
		mousedown_node = null
		mouseup_node = null

		resetMouseVars = ->
			mousedown_node = null
			mouseup_node = null
			mousedown_link = null
			return

		resize = ->
			width = if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
			height = window.innerHeight
			svg.attr('width', width).attr 'height', height
			force.size([
				width
				height + 80
			]).resume()
			return

		# update force layout (called automatically each iteration)
		tick = ->
			# draw directed edges with proper padding from node centers
			allPathes.attr 'd', (d) ->
				deltaX = d.target.x - (d.source.x)
				deltaY = d.target.y - (d.source.y)
				dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
				normX = deltaX / dist
				normY = deltaY / dist
				sourcePadding = if d.left then 17 else 12
				targetPadding = if d.right then 17 else 12
				sourceX = d.source.x + sourcePadding * normX
				sourceY = d.source.y + sourcePadding * normY
				targetX = d.target.x - (targetPadding * normX)
				targetY = d.target.y - (targetPadding * normY)
				'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY
			allCircles.attr 'transform', (d) ->
				'translate(' + d.x + ',' + d.y + ')'
			return

		# update graph (called when needed)
		restart = ->
			# path (link) group
			allPathes = allPathes.data(net.edges)
			# update existing links
			allPathes.classed('selected', (d) ->
				d == selected_link
			).style('marker-start', (d) ->
				if d.left then 'url(#start-arrow)' else ''
			).style 'marker-end', (d) ->
				if d.right then 'url(#end-arrow)' else ''
			# add new links
			allPathes.enter().append('svg:path').attr('class', 'link').classed('selected', (d) ->
				d == selected_link
			).style('marker-start', (d) ->
				if d.left then 'url(#start-arrow)' else ''
			).style('marker-end', (d) ->
				if d.right then 'url(#end-arrow)' else ''
			).on 'mousedown', (d) ->
				if d3.event.ctrlKey
					return
				# select link
				mousedown_link = d
				if mousedown_link == selected_link
					selected_link = null
				else
					selected_link = mousedown_link
				selected_node = null
				restart()
				return
			# remove old links
			allPathes.exit().remove()
			# circle (node) group
			# NB: the function arg is crucial here! nodes are known by id, not by index!
			allCircles = allCircles.data(net.nodes, (d) ->
				d.id
			)
			# update existing nodes (reflexive & selected visual states)
			allCircles.selectAll('circle').style('fill', (d) ->
				if d == selected_node then d3.rgb(colors(d.id)).brighter().toString() else colors(d.id)
			).classed 'reflexive', (d) ->
				d.reflexive
			# add new nodes
			g = allCircles.enter().append('svg:g')
			g.append('svg:circle').attr('class', 'node').attr('r', 12).style('fill', (d) ->
				if d == selected_node then d3.rgb(colors(d.id)).brighter().toString() else colors(d.id)
			).style('stroke', (d) ->
				d3.rgb(colors(d.id)).darker().toString()
			).classed('reflexive', (d) ->
				d.reflexive
			).on('mouseover', (d) ->
				if !mousedown_node or d == mousedown_node
					return
				# enlarge target node
				d3.select(this).attr 'transform', 'scale(1.1)'
				return
			).on('mouseout', (d) ->
				if !mousedown_node or d == mousedown_node
					return
				# unenlarge target node
				d3.select(this).attr 'transform', ''
				return
			).on('mousedown', (d) ->
				if d3.event.ctrlKey
					return
				# select node
				mousedown_node = d
				if mousedown_node == selected_node
					selected_node = null
				else
					selected_node = mousedown_node
				selected_link = null
				# reposition drag line
				drag_line.style('marker-end', 'url(#end-arrow)').classed('hidden', false).attr 'd', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + mousedown_node.x + ',' + mousedown_node.y
				restart()
				return
			).on 'mouseup', (d) ->
				if !mousedown_node
					return
				# needed by FF
				drag_line.classed('hidden', true).style 'marker-end', ''
				# check for drag-to-self
				mouseup_node = d
				if mouseup_node == mousedown_node
					resetMouseVars()
					return
				# unenlarge target node
				d3.select(this).attr 'transform', ''
				# add link to graph (update if exists)
				# NB: links are strictly source < target; arrows separately specified by booleans
				source = undefined
				target = undefined
				direction = undefined
				if mousedown_node.id < mouseup_node.id
					source = mousedown_node
					target = mouseup_node
					direction = 'right'
				else
					source = mouseup_node
					target = mousedown_node
					direction = 'left'
				link = undefined
				link = net.edges.filter((l) ->
					l.source == source and l.target == target
				)[0]
				if link
					link[direction] = true
				else
					link =
						source: source
						target: target
						left: false
						right: false
					link[direction] = true
					net.edges.push link
					$scope.$apply()
					# Quick save net to storage
				# select new link
				selected_link = link
				selected_node = null
				restart()
				return
			# show node IDs
			g.append('svg:text').attr('x', 0).attr('y', 4).attr('class', 'id').text (d) ->
				d.id
			# remove old nodes
			allCircles.exit().remove()
			# set the graph in motion
			force.start()
			return

		mousedown = ->
			# because :active only works in WebKit?
			svg.classed 'active', true
			if d3.event.ctrlKey or mousedown_node or mousedown_link
				return
			# insert new node at point
			point = d3.mouse(this)
			net.addNode point
			$scope.$apply()
			# Quick save net to storage
			restart()
			return

		mousemove = ->
			if !mousedown_node
				return
			# update drag line
			drag_line.attr 'd', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + d3.mouse(this)[0] + ',' + d3.mouse(this)[1]
			restart()
			return

		mouseup = ->
			if mousedown_node
				# hide drag line
				drag_line.classed('hidden', true).style 'marker-end', ''
			# because :active only works in WebKit?
			svg.classed 'active', false
			# clear mouse event vars
			resetMouseVars()
			return

		spliceLinksForNode = (node) ->
			toSplice = net.edges.filter((l) ->
				l.source == node or l.target == node
			)
			toSplice.map (l) ->
				net.edges.splice net.edges.indexOf(l), 1
				return
			return

		$scope.undo = ->
			net = net.undo()
			restart()
			return

		$scope.redo = ->
			net.redo()
			return

		resize()
		d3.select(window).on 'resize', resize
		# init D3 force layout
		force = force.nodes(net.nodes).links(net.edges).size([
			if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
			window.innerHeight + 80
		]).linkDistance(150).charge(-500).on('tick', tick)
		# fix lost references to nodes
		i = 0
		while i < net.edges.length
			net.edges[i].source = net.nodes.filter((node) ->
				node.id == net.edges[i].source.id
			)[0]
			net.edges[i].target = net.nodes.filter((node) ->
				node.id == net.edges[i].target.id
			)[0]
			i++
		# app starts here
		svg.on('mousedown', mousedown).on('mousemove', mousemove).on 'mouseup', mouseup
		restart()
		return
