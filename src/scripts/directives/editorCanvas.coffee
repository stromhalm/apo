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
		lastTouchTapNode = null
		lastTouchTapAt = 0
		touchTapCandidateNode = null
		touchTapStartPoint = null
		touchTapMoved = false

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

		getTouchClientPoint = (event) ->
			touch = event.touches?[0] or event.changedTouches?[0]
			return null if not touch
			{x: touch.clientX, y: touch.clientY}

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
				touchTapCandidateNode = getEventNode(event.target)
				touchTapStartPoint = getTouchClientPoint(event)
				touchTapMoved = false

				return if $scope.net.getActiveTool().name isnt "Arrows"
				node = getEventNode(event.target)
				return if not node
				event.preventDefault()
				$scope.$evalAsync(-> $scope.mouseDownOnNode(node, event))

			touchMoveHandler = (event) ->
				currentPoint = getTouchClientPoint(event)
				if touchTapStartPoint and currentPoint
					deltaX = currentPoint.x - touchTapStartPoint.x
					deltaY = currentPoint.y - touchTapStartPoint.y
					touchTapMoved = true if Math.sqrt(deltaX * deltaX + deltaY * deltaY) > 10

				return if $scope.net.getActiveTool().name isnt "Arrows"
				return if not mouseDownNode
				event.preventDefault()
				$scope.$evalAsync(-> $scope.mouseMoveOnCanvas(event))

			touchEndHandler = (event) ->
				targetNode = getEventNode(getTouchTarget(event))
				activeTool = $scope.net.getActiveTool()
				if activeTool.name is "Arrows" and mouseDownNode
					event.preventDefault()
					$scope.$evalAsync ->
						if targetNode
							$scope.mouseUpOnNode(targetNode, event)
						else
							$scope.mouseUpOnCanvas(event)
					touchTapCandidateNode = null
					touchTapStartPoint = null
					touchTapMoved = false
					return

				if not touchTapMoved and targetNode and targetNode is touchTapCandidateNode
					now = Date.now()
					if lastTouchTapNode is targetNode and now - lastTouchTapAt < 350
						event.preventDefault()
						$scope.$evalAsync(-> $scope.dblClickOnNode(targetNode, event))
						lastTouchTapNode = null
						lastTouchTapAt = 0
					else
						lastTouchTapNode = targetNode
						lastTouchTapAt = now
				else if touchTapMoved
					lastTouchTapNode = null
					lastTouchTapAt = 0

				touchTapCandidateNode = null
				touchTapStartPoint = null
				touchTapMoved = false

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


class EditorCanvas extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/editorCanvas.html"
			controller: EditorCanvasController
		}
