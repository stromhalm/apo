class EditorCanvasController extends Controller
	constructor: ($timeout, $scope, $state, $stateParams, netStorageService, converterService, formDialogService) ->

		# Set net model physics
		charge = -500
		linkStrength = 0.1
		friction = 0.9
		gravity = 0.1

		# Delte net via the error card
		$scope.deleteNet = () -> netStorageService.deleteNet($scope.net.name)

		$scope.net = netStorageService.getNetByName(decodeURI($stateParams.name))

		console.log $scope.net

		if not $scope.net
			$state.go "editor", name: netStorageService.nets[0].name
			return

		isFiniteNumber = (value) ->
			isFinite(value)

		isForceSimulation = (simulation) ->
			typeof simulation?.stop is 'function' and typeof simulation?.size is 'function' and typeof simulation?.resume is 'function'

		normalizeNodePosition = (node) ->
			node.x = if isFiniteNumber(node.x) then node.x else if isFiniteNumber(node.px) then node.px else 0
			node.y = if isFiniteNumber(node.y) then node.y else if isFiniteNumber(node.py) then node.py else 0
			node.px = if isFiniteNumber(node.px) then node.px else node.x
			node.py = if isFiniteNumber(node.py) then node.py else node.y
			node

		# Adjust SVG canvas on window resize
		resize = ->
			return if not isForceSimulation($scope.net.simulation)
			$scope.net.simulation.size([
				if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
				$scope.height = window.innerHeight - 146
			]).resume()
		window.onresize = resize

		# Initialize d3 force layout
		$scope.net.refresh = ->
			$scope.net.simulation.stop() if isForceSimulation($scope.net.simulation)
			normalizeNodePosition(node) for node in $scope.net.nodes
			$scope.net.simulation = d3.layout.force()
				.nodes($scope.net.nodes)
				.links($scope.net.edges)
				.linkDistance((edge) -> edge.length)
				.linkStrength(linkStrength)
				.friction(friction)
				.charge(charge)
				.gravity(gravity)
				.on('tick', -> $scope.$apply())
				.start()
			resize()
		$scope.net.refresh()
		# Refresh layout when the number of nodes/edges changes
		$scope.$watchGroup ['net.nodes.length', 'net.edges.length'], $scope.net.refresh

		mouseDownNode = null
		mouseDownEdge = null
		snapTargetNode = null
		dragLine = null
		touchCanvas = null
		touchStartHandler = null
		touchMoveHandler = null
		touchEndHandler = null

		getDragLine = ->
			dragLine = d3.select('.editor-canvas .dragline')

		resetMouseVars = ->
			mouseDownNode = null
			mouseDownEdge = null
			snapTargetNode = null

		restart = ->
			$scope.$evalAsync()

		getPoint = (event) ->
			svgElement = document.querySelector('.editor-canvas svg')
			rect = svgElement?.getBoundingClientRect()
			touch = event.touches?[0] or event.changedTouches?[0]
			clientX = touch?.clientX ? event.clientX
			clientY = touch?.clientY ? event.clientY
			left = rect?.left ? 0
			top = rect?.top ? 0

			x = if isFiniteNumber(clientX) then clientX - left else event.offsetX
			y = if isFiniteNumber(clientY) then clientY - top else event.offsetY

			new Point({
				x: if isFiniteNumber(x) then x else 0
				y: if isFiniteNumber(y) then y else 0
			})

		getNodeById = (id) ->
			return false if not isFiniteNumber(id)
			return node for node in $scope.net.nodes when node.id is id
			false

		getEventNode = (eventTarget) ->
			nodeElement = eventTarget?.closest?('.node-group')
			nodeId = parseInt(nodeElement?.getAttribute('data-node-id'), 10)
			getNodeById(nodeId)

		getTouchTarget = (event) ->
			touch = event.changedTouches?[0] or event.touches?[0]
			return document.elementFromPoint(touch.clientX, touch.clientY) if touch and document.elementFromPoint
			event.target

		getPointerTarget = (event) ->
			return getTouchTarget(event) if event.touches or event.changedTouches
			event.target

		getSnapTarget = (node) ->
			return null if not mouseDownNode
			return null if $scope.net.getActiveTool().name isnt "Arrows"
			return null if not node or node is mouseDownNode
			return null if not $scope.net.isConnectable(mouseDownNode, node)
			node

		updateSnapTarget = (eventOrTarget) ->
			target = if eventOrTarget?.target or eventOrTarget?.touches or eventOrTarget?.changedTouches then getPointerTarget(eventOrTarget) else eventOrTarget
			snapTargetNode = getSnapTarget(getEventNode(target))
			snapTargetNode

		getDragTargetPoint = (event) ->
			updateSnapTarget(event)
			return new Point({x: snapTargetNode.x, y: snapTargetNode.y}) if snapTargetNode
			getPoint(event)

		getDragPreviewMarkers = (targetNode) ->
			return {start: false, end: true} if not mouseDownNode or not targetNode

			existingSame = null
			existingReverse = null

			for edge in $scope.net.edges when edge.source is mouseDownNode and edge.target is targetNode
				existingSame = edge

			for edge in $scope.net.edges when edge.source is targetNode and edge.target is mouseDownNode
				existingReverse = edge

			if existingSame
				return {
					start: existingSame.left > 0
					end: true
				}

			if existingReverse
				return {
					start: existingReverse.right > 0
					end: true
				}

			{
				start: false
				end: true
			}

		renderDragPreview = (point, targetNode = null) ->
			markers = getDragPreviewMarkers(targetNode)
			path = 'M' + mouseDownNode.x + ',' + mouseDownNode.y + 'L' + point.x + ',' + point.y
			if targetNode
				previewEdge = new Edge({
					source: mouseDownNode
					target: targetNode
					left: if markers.start then 1 else 0
					right: if markers.end then 1 else 0
				})
				path = previewEdge.getPath()
			getDragLine()
				.style('marker-start', if markers.start then 'url(#startArrow)' else '')
				.style('marker-end', if markers.end then 'url(#endArrow)' else '')
				.attr('d', path)

		installTouchHandlers = ->
			touchCanvas = document.querySelector('.editor-canvas svg')
			return if not touchCanvas

			touchStartHandler = (event) ->
				return if $scope.net.getActiveTool().name isnt "Arrows"
				node = getEventNode(event.target)
				return if not node
				event.preventDefault()
				$scope.$evalAsync(-> $scope.mouseDownOnNode(node, event))

			touchMoveHandler = (event) ->
				return if $scope.net.getActiveTool().name isnt "Arrows"
				return if not mouseDownNode
				event.preventDefault()
				$scope.$evalAsync(-> $scope.mouseMoveOnCanvas(event))

			touchEndHandler = (event) ->
				return if $scope.net.getActiveTool().name isnt "Arrows"
				return if not mouseDownNode
				event.preventDefault()
				targetNode = getEventNode(getTouchTarget(event))
				$scope.$evalAsync ->
					if targetNode
						$scope.mouseUpOnNode(targetNode, event)
					else
						$scope.mouseUpOnCanvas(event)

			touchCanvas.addEventListener('touchstart', touchStartHandler, {passive: false})
			touchCanvas.addEventListener('touchmove', touchMoveHandler, {passive: false})
			touchCanvas.addEventListener('touchend', touchEndHandler, {passive: false})
			touchCanvas.addEventListener('touchcancel', touchEndHandler, {passive: false})

		stopEvent = (event) ->
			return if not event
			event.preventDefault()
			event.stopPropagation()

		$scope.clickOnCanvas = (event) ->
			return if mouseDownNode or mouseDownEdge
			$scope.net.getActiveTool().clickOnCanvas($scope.net, getPoint(event), getDragLine(), formDialogService, restart, converterService)

		$scope.dblClickOnCanvas = (event) ->
			return if mouseDownNode or mouseDownEdge
			$scope.net.getActiveTool().dblClickOnCanvas($scope.net, getPoint(event), getDragLine(), formDialogService, restart, converterService)

		$scope.mouseDownOnCanvas = (event) ->
			return if mouseDownNode or mouseDownEdge
			$scope.net.getActiveTool().mouseDownOnCanvas($scope.net, getPoint(event), getDragLine(), formDialogService, restart, converterService)

		$scope.mouseMoveOnCanvas = (event) ->
			return if not mouseDownNode
			point = getDragTargetPoint(event)
			renderDragPreview(point, snapTargetNode)

		$scope.mouseUpOnCanvas = (event) ->
			activeTool = $scope.net.getActiveTool()
			if mouseDownNode and snapTargetNode and activeTool.name is "Arrows"
				activeTool.mouseUpOnNode($scope.net, snapTargetNode, mouseDownNode, getDragLine(), formDialogService, restart, converterService)
			else if mouseDownNode
				getDragLine().classed('hidden', true).style('marker-start', '').style('marker-end', '')
			resetMouseVars()

		$scope.clickOnNode = (node, event) ->
			stopEvent(event)
			$scope.net.getActiveTool().clickOnNode($scope.net, node, getDragLine(), formDialogService, restart, converterService)

		$scope.dblClickOnNode = (node, event) ->
			stopEvent(event)
			$scope.net.getActiveTool().dblClickOnNode($scope.net, node, getDragLine(), formDialogService, restart, converterService)

		$scope.mouseDownOnNode = (node, event) ->
			stopEvent(event)
			activeTool = $scope.net.getActiveTool()
			mouseDownEdge = null
			snapTargetNode = null
			if activeTool.draggable
				activeTool.mouseDownOnNode($scope.net, node, getDragLine(), formDialogService, restart, converterService)
				return
			mouseDownNode = node
			activeTool.mouseDownOnNode($scope.net, node, getDragLine(), formDialogService, restart, converterService)

		$scope.mouseUpOnNode = (node, event) ->
			activeTool = $scope.net.getActiveTool()
			if activeTool.draggable
				resetMouseVars()
				return
			stopEvent(event)
			activeTool.mouseUpOnNode($scope.net, node, mouseDownNode, getDragLine(), formDialogService, restart, converterService)
			resetMouseVars()

		$scope.clickOnEdge = (edge, event) ->
			stopEvent(event)
			$scope.net.getActiveTool().clickOnEdge($scope.net, edge, getDragLine(), formDialogService, restart, converterService)

		$scope.dblClickOnEdge = (edge, event) ->
			stopEvent(event)
			$scope.net.getActiveTool().dblClickOnEdge($scope.net, edge, getDragLine(), formDialogService, restart, converterService)

		$scope.mouseDownOnEdge = (edge, event) ->
			stopEvent(event)
			mouseDownEdge = edge
			mouseDownNode = null
			$scope.net.getActiveTool().mouseDownOnEdge($scope.net, edge, formDialogService, restart, converterService)

		$scope.mouseUpOnEdge = (edge, event) ->
			stopEvent(event)
			$scope.net.getActiveTool().mouseUpOnEdge($scope.net, edge, getDragLine(), formDialogService, restart, converterService)
			resetMouseVars()

		$scope.isSnapTarget = (node) ->
			snapTargetNode is node

		$timeout(installTouchHandlers)

		$scope.$on '$destroy', ->
			return if not touchCanvas
			touchCanvas.removeEventListener('touchstart', touchStartHandler, {passive: false}) if touchStartHandler
			touchCanvas.removeEventListener('touchmove', touchMoveHandler, {passive: false}) if touchMoveHandler
			touchCanvas.removeEventListener('touchend', touchEndHandler, {passive: false}) if touchEndHandler
			touchCanvas.removeEventListener('touchcancel', touchEndHandler, {passive: false}) if touchEndHandler
		
		###
			svg = d3.select('.editor-canvas svg')
			force = d3.layout.force()
			drag = force.drag()
			dragLine = svg.select('svg .dragline')
			edges = svg.append('svg:g').selectAll('.edge')
			# nodes = svg.append('svg:g').selectAll('g')

			# mouse event vars
			selectedNode = null
			mouseDownEdge = null
			mouseDownNode = null
			mouseUpNode = null

			resetMouseVars = ->
				mouseDownNode = null
				mouseUpNode = null
				mouseDownEdge = null

			# update net positions (called each iteration)
			tick = ->
				# draw directed edges with proper padding from node centers
				edges.attr 'd', (edge) ->
					edge = new Edge(edge)
					edge.getPath()
				#nodes.attr 'transform', (d) ->
				#	'translate(' + d.x + ',' + d.y + ')'

			# update graph layout (called when needed)
			restart = ->
				edges = edges.data($scope.net.edges)

				# update existing links
				edges.style('marker-start', (edge) -> if edge.left > 0 then 'url(#startArrow)' else '')
				edges.style('marker-end', (edge) -> if edge.right > 0 then 'url(#endArrow)' else '')

				# update existing edge labels
				d3.selectAll('.edgeLabel .text').text((edge) -> converterService.getEdgeFromData(edge).getText())

				# add edge labels
				edges.enter().append('svg:text').attr('dy', -8).attr('class', 'label edgeLabel')
				.attr('id', (edge) -> 'edgeLabel-' + edge.id)
				.append('textPath').attr('startOffset', '50%').attr('class', 'text')
				.attr('xlink:href', (edge) -> '#edge-' + edge.id).text((edge) -> converterService.getEdgeFromData(edge).getText())

				# add new egdes
				edges.enter().append('svg:path').attr('class', 'link')
					.style('marker-start', (edge) -> if edge.left > 0 then 'url(#startArrow)' else '')
					.style('marker-end', (edge) -> if edge.right > 0 then 'url(#endArrow)' else '')
					.attr('id', (edge) -> 'edge-' + edge.id)
					.classed('edge', true)
					.on 'mousedown', (edge) ->
						mouseDownEdge = edge
						selectedNode = null

						# call the tools mouseDown listener
						$scope.net.getActiveTool().mouseDownOnEdge(net, mouseDownEdge, formDialogService, restart, converterService)
						$scope.$apply() # Quick save net to storage
						restart()

				# remove old links
				# edges.exit().each((edge) -> d3.selectAll('#edgeLabel-' + edge.id).remove()).remove()

				# nodes = nodes.data(net.nodes, (node) -> node.id)

				# update existing nodes
				# nodes.selectAll('.node').classed('firable', (node) ->  net.isFirable(node))

				# update existing node labels
				# d3.selectAll('.nodeLabel').text((node) -> converterService.getNodeFromData(node).getText())
				# d3.selectAll('.token').text((node) -> converterService.getNodeFromData(node).getTokenLabel())
				# d3.selectAll('.self-edge-label .text').text((node) -> converterService.getNodeFromData(node).getSelfEdgeText())
				# d3.selectAll('.self-edge').classed('hidden', (node) -> node.labelsToSelf and node.labelsToSelf.length is 0)

				# add new nodes
				# newNodes = nodes.enter().append('svg:g')
				# newNodes.append((node) -> document.createElementNS("http://www.w3.org/2000/svg", converterService.getNodeFromData(node).shape))
				# .attr('class', (node) -> node.type + ' node')
				# .attr('r', (node) -> node.radius)
				# .attr('width', (node) -> node.width)
				# .attr('height', (node) -> node.height)
				# .classed('firable', (node) ->  net.isFirable(node))
				# .on 'mouseover', (node) ->
				# 	return if !mouseDownNode or node == mouseDownNode or !net.isConnectable(mouseDownNode, node)
				# 	d3.select(this).style('fill', 'rgb(235, 235, 235)') # highlight target node

				# .on 'mouseout', (node) ->
				# 	return if !mouseDownNode or node == mouseDownNode
				# 	d3.select(this).attr 'style', '' # unhighlight target node

				# .on 'mousedown', (node) ->

					# select node
				# 	mouseDownNode = node
				#	if mouseDownNode == selectedNode
				#		selectedNode = null
				#	else
				#		selectedNode = mouseDownNode

					# call the tools mouseDown listener
				#	net.getActiveTool().mouseDownOnNode(net, mouseDownNode, dragLine, formDialogService, restart, converterService)
				#	$scope.$apply() # Quick save net to storage
				#	restart()

				#.on 'mouseup', (node) ->
				#	mouseUpNode = node

				#	d3.select(this).style('fill', '') # unhighlight target node
				#	net.getActiveTool().mouseUpOnNode(net, mouseUpNode, mouseDownNode, dragLine)
				#	$scope.$apply() # Quick save net to storage

				#	selectedNode = null
				#	restart()

				#.on 'dblclick', (node) ->
				#	net.getActiveTool().dblClickOnNode(net, node)
				#	restart()

				#.on 'touchend', (startNode) ->

					# We need to calculate the nearest node by ourselves
				#	smallestDistance = 50
				#	nearestNode = null
				#	for node in net.nodes
				#		xOffset = d3.mouse(this)[0]+startNode.x - node.x
				#		yOffset = d3.mouse(this)[1]+startNode.y - node.y
				#		distance = Math.sqrt(xOffset*xOffset+yOffset*yOffset)
				#		if distance < smallestDistance
				#			smallestDistance = distance
				#			nearestNode = node
					
				#	if nearestNode
				#		mouseUpNode = nearestNode
				#		net.getActiveTool().mouseUpOnNode(net, mouseUpNode, mouseDownNode, dragLine)
				#		$scope.$apply() # Quick save net to storage

				#		selectedNode = null
				#		restart()

				# show node text
				#newNodes.append('svg:text').attr('x', (node) -> node.labelXoffset).attr('y', (node) -> node.labelYoffset).attr('class', 'label nodeLabel').text((node) -> converterService.getNodeFromData(node).getText())
				#newNodes.append('svg:text').attr('x', 0).attr('y', 4).attr('class', 'label token').text((node) -> converterService.getNodeFromData(node).getTokenLabel())

				#add edge to self
				#newNodes.append('svg:path').attr('class', 'link edge self-edge')
				#	.style('marker-end', 'url(#endArrow)')
				#	.attr('id', (node) -> 'self-edge-' + node.id)
				#	.attr('d', (node) -> converterService.getNodeFromData(node).getSelfEdgePath())
				#	.classed('hidden', (node) -> node.labelsToSelf and node.labelsToSelf.length is 0)
				#	.on 'mousedown', (node) ->
						# call the tools mouseDown listener
				#		net.getActiveTool().mouseDownOnNode(net, node, dragLine, formDialogService, restart, converterService)

				#newNodes.append('svg:text').attr('dy', -4).attr('class', 'label self-edge-label')
				#	.append('textPath').attr('startOffset', '50%').attr('class', 'text')
				#	.attr('xlink:href', (node) -> '#self-edge-' + node.id)
				#	.text((node) -> converterService.getNodeFromData(node).getSelfEdgeText())

				#nodes.exit().remove() # remove old nodes
				#force.start() # set the graph in motion

			mousedown = ->
				svg.classed 'active', true
				return if mouseDownNode or mouseDownEdge

				# fire the current tool's mouseDown listener
				point = new Point({x: d3.mouse(this)[0], y: d3.mouse(this)[1]})
				$scope.net.getActiveTool().mouseDownOnCanvas(net, point)
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

			# fix lost references to nodes
			# for edge in $scope.net.edges
			#	edge.source = $scope.net.nodes.filter((node) -> node.id == edge.source.id)[0]
			#	edge.target = $scope.net.nodes.filter((node) -> node.id == edge.target.id)[0]

			# motion starts here
			svg.on('mousedown', mousedown)
			.on('mousemove', mousemove)
			.on('mouseup', mouseup)
			.on('touchmove', mousemove)
			.on('touchend', mouseup)
			restart()
			

		document.body.addEventListener('touchmove', (e) -> e.preventDefault())

		catch error
			console.error error
			force.stop()
			$scope.error = true
		###
		

class EditorCanvas extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/editorCanvas.html"
			controller: EditorCanvasController
		}
