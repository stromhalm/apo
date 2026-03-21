class EditorCanvasController extends Controller
	constructor: ($timeout, $scope, $state, $stateParams, netStorageService, converterService, formDialogService) ->

		# Set net model physics
		charge = -500
		linkStrength = 0.1
		friction = 0.9
		gravity = 0.1
		zoomButtonFactor = 1.2
		zoomAnimationDuration = 180
		trackpadZoomFactor = 1.004
		mouseWheelZoomFactor = 1.06
		panThreshold = 3
		tapMoveThreshold = 10
		lineWheelFactor = 16
		wheelPanFactor = 1

		# Delete net via the error card
		$scope.deleteNet = () -> netStorageService.deleteNet($scope.net.name)

		$scope.net = netStorageService.getNetByName(decodeURI($stateParams.name))

		if not $scope.net
			$state.go "editor", name: netStorageService.nets[0].name
			return

		$scope.viewport = new EditorViewport()
		$scope.isPanningCanvas = false

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

		getSvgElement = ->
			document.querySelector('.editor-canvas svg')

		getSvgRect = ->
			getSvgElement()?.getBoundingClientRect()

		getClientPoint = (event, touchIndex = 0) ->
			touch = event.touches?[touchIndex] or event.changedTouches?[touchIndex]
			return {x: touch.clientX, y: touch.clientY} if touch
			return {x: event.clientX, y: event.clientY} if isFiniteNumber(event.clientX) and isFiniteNumber(event.clientY)

			rect = getSvgRect()
			left = rect?.left ? 0
			top = rect?.top ? 0
			{
				x: if isFiniteNumber(event.offsetX) then left + event.offsetX else left
				y: if isFiniteNumber(event.offsetY) then top + event.offsetY else top
			}

		getViewportCenterClientPoint = ->
			rect = getSvgRect()
			left = rect?.left ? 0
			top = rect?.top ? 0
			width = rect?.width ? 0
			height = rect?.height ? 0
			{
				x: left + width / 2
				y: top + height / 2
			}

		getPointFromClient = (clientX, clientY) ->
			canvasPoint = $scope.viewport.getCanvasPoint(clientX, clientY, getSvgRect())
			new Point({
				x: canvasPoint.x
				y: canvasPoint.y
			})

		getPoint = (event, touchIndex = 0) ->
			clientPoint = getClientPoint(event, touchIndex)
			getPointFromClient(clientPoint.x, clientPoint.y)

		$scope.getCanvasPointFromClient = (clientX, clientY) ->
			getPointFromClient(clientX, clientY)

		getNodeById = (id) ->
			return false if not isFiniteNumber(id)
			return node for node in $scope.net.nodes when node.id is id
			false

		getEventNode = (eventTarget) ->
			nodeElement = eventTarget?.closest?('.node-group')
			nodeId = parseInt(nodeElement?.getAttribute('data-node-id'), 10)
			getNodeById(nodeId)

		getEventEdge = (eventTarget) ->
			edgeElement = eventTarget?.closest?('[data-edge-id]')
			edgeId = parseInt(edgeElement?.getAttribute('data-edge-id'), 10)
			return false if not isFiniteNumber(edgeId)
			return edge for edge in $scope.net.edges when edge.id is edgeId
			false

		getTouchTarget = (event, touchIndex = 0) ->
			touch = event.changedTouches?[touchIndex] or event.touches?[touchIndex]
			return document.elementFromPoint(touch.clientX, touch.clientY) if touch and document.elementFromPoint
			event.target

		getTouchClientPoint = (event, touchIndex = 0) ->
			return null if not event.touches?[touchIndex] and not event.changedTouches?[touchIndex]
			getClientPoint(event, touchIndex)

		getTouchDistance = (event) ->
			return 0 if event.touches?.length < 2
			firstTouch = getTouchClientPoint(event, 0)
			secondTouch = getTouchClientPoint(event, 1)
			return 0 if not firstTouch or not secondTouch
			deltaX = secondTouch.x - firstTouch.x
			deltaY = secondTouch.y - firstTouch.y
			Math.sqrt(deltaX * deltaX + deltaY * deltaY)

		getTouchMidpoint = (event) ->
			return null if event.touches?.length < 2
			firstTouch = getTouchClientPoint(event, 0)
			secondTouch = getTouchClientPoint(event, 1)
			return null if not firstTouch or not secondTouch
			{
				x: (firstTouch.x + secondTouch.x) / 2
				y: (firstTouch.y + secondTouch.y) / 2
			}

		getPointerTarget = (event) ->
			return getTouchTarget(event) if event.touches or event.changedTouches
			event.target

		isZoomControlTarget = (eventTarget) ->
			!!eventTarget?.closest?('.canvas-zoom-controls')

		isBackgroundTarget = (eventTarget) ->
			return false if isZoomControlTarget(eventTarget)
			not getEventNode(eventTarget) and not getEventEdge(eventTarget)

		panState =
			active: false
			startClientPoint: null
			lastClientPoint: null
			moved: false

		pinchState = null
		mouseDownNode = null
		mouseDownEdge = null
		snapTargetNode = null
		dragLine = null
		touchCanvas = null
		touchStartHandler = null
		touchMoveHandler = null
		touchEndHandler = null
		wheelHandler = null
		zoomAnimationFrame = null
		lastTouchTapNode = null
		lastTouchTapAt = 0
		touchTapCandidateNode = null
		touchTapStartPoint = null
		touchTapMoved = false
		suppressCanvasClick = false
		suppressCanvasDoubleClick = false

		# Adjust SVG canvas on window resize
		resize = ->
			return if not isForceSimulation($scope.net.simulation)
			$scope.net.simulation.size([
				if window.innerWidth > 960 then window.innerWidth - 245 else window.innerWidth
				$scope.height = window.innerHeight - 146
			]).resume()

		window.addEventListener('resize', resize)

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

		getDragLine = ->
			dragLine = d3.select('.editor-canvas .dragline')

		clearDragLine = ->
			getDragLine().classed('hidden', true).style('marker-start', '').style('marker-end', '')

		resetMouseVars = ->
			mouseDownNode = null
			mouseDownEdge = null
			snapTargetNode = null

		cancelArrowPreview = ->
			return if not mouseDownNode
			clearDragLine()
			resetMouseVars()

		restart = ->
			$scope.$evalAsync()

		cancelZoomAnimation = ->
			return if not zoomAnimationFrame
			window.cancelAnimationFrame?(zoomAnimationFrame)
			window.clearTimeout?(zoomAnimationFrame)
			zoomAnimationFrame = null

		requestAnimationFrameCompat = (callback) ->
			if window.requestAnimationFrame
				window.requestAnimationFrame(callback)
			else
				window.setTimeout((-> callback(Date.now())), 16)

		applyZoom = (nextScale, clientPoint = getViewportCenterClientPoint()) ->
			return if not clientPoint
			$scope.viewport.zoomAroundClientPoint(nextScale, clientPoint.x, clientPoint.y, getSvgRect())

		zoomByFactor = (factor, clientPoint = getViewportCenterClientPoint()) ->
			applyZoom($scope.viewport.scale * factor, clientPoint)

		animateZoomByFactor = (factor, clientPoint = getViewportCenterClientPoint()) ->
			return if not clientPoint
			cancelZoomAnimation()

			startScale = $scope.viewport.scale
			targetScale = EditorViewport.clampScale(startScale * factor)
			return if targetScale is startScale

			startedAt = null
			step = (timestamp) ->
				startedAt = timestamp if not startedAt
				progress = Math.min((timestamp - startedAt) / zoomAnimationDuration, 1)
				easedProgress = 1 - Math.pow(1 - progress, 3)
				currentScale = startScale + (targetScale - startScale) * easedProgress
				applyZoom(currentScale, clientPoint)

				if progress < 1
					zoomAnimationFrame = requestAnimationFrameCompat(step)
					$scope.$evalAsync()
				else
					zoomAnimationFrame = null
					$scope.$evalAsync()

			zoomAnimationFrame = requestAnimationFrameCompat(step)

		startPan = (clientPoint) ->
			return if not clientPoint
			panState.active = true
			panState.startClientPoint = clientPoint
			panState.lastClientPoint = clientPoint
			panState.moved = false
			$scope.isPanningCanvas = true

		updatePan = (clientPoint) ->
			return if not panState.active or not clientPoint
			deltaX = clientPoint.x - panState.lastClientPoint.x
			deltaY = clientPoint.y - panState.lastClientPoint.y
			$scope.viewport.panBy(deltaX, deltaY)
			panState.lastClientPoint = clientPoint

			totalX = clientPoint.x - panState.startClientPoint.x
			totalY = clientPoint.y - panState.startClientPoint.y
			panState.moved = true if Math.sqrt(totalX * totalX + totalY * totalY) > panThreshold

		finishPan = ->
			return false if not panState.active
			didMove = panState.moved
			panState.active = false
			panState.startClientPoint = null
			panState.lastClientPoint = null
			panState.moved = false
			$scope.isPanningCanvas = false

			if didMove
				suppressCanvasClick = true
				suppressCanvasDoubleClick = true

			didMove

		normalizeWheelValue = (value, event, factor = 1) ->
			multiplier = 1
			if event.deltaMode is 1
				multiplier = lineWheelFactor
			else if event.deltaMode is 2
				multiplier = getSvgRect()?.height ? window.innerHeight
			value * multiplier * factor

		isLikelyTrackpadWheel = (event) ->
			return true if event.ctrlKey
			return false if event.deltaMode and event.deltaMode isnt 0

			deltaX = Math.abs(event.deltaX ? 0)
			deltaY = Math.abs(event.deltaY ? 0)
			wheelDeltaY = Math.abs(event.wheelDeltaY ? event.wheelDelta ? 0)
			hasFractionalDelta = deltaX % 1 isnt 0 or deltaY % 1 isnt 0

			return false if wheelDeltaY and wheelDeltaY % 120 is 0 and deltaX is 0
			return true if deltaX > 0
			return true if hasFractionalDelta
			false

		getMouseWheelZoomSteps = (event) ->
			deltaY = event.deltaY ? 0
			switch event.deltaMode
				when 1 then deltaY
				when 2 then deltaY / 6
				else deltaY / 40

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

		beginPinch = (event) ->
			return if event.touches?.length < 2
			cancelArrowPreview() if $scope.net.getActiveTool().name is "Arrows"
			finishPan() if panState.active
			midpoint = getTouchMidpoint(event)
			pinchState =
				distance: getTouchDistance(event)
				scale: $scope.viewport.scale
				anchorPoint: if midpoint then $scope.viewport.getCanvasPoint(midpoint.x, midpoint.y, getSvgRect()) else null

		updatePinch = (event) ->
			return if not pinchState or event.touches?.length < 2
			midpoint = getTouchMidpoint(event)
			distance = getTouchDistance(event)
			return if not midpoint or distance is 0 or pinchState.distance is 0 or not pinchState.anchorPoint
			rect = getSvgRect()
			nextScale = EditorViewport.clampScale(pinchState.scale * distance / pinchState.distance)
			left = rect?.left ? 0
			top = rect?.top ? 0
			$scope.viewport.scale = nextScale
			$scope.viewport.translateX = midpoint.x - left - pinchState.anchorPoint.x * nextScale
			$scope.viewport.translateY = midpoint.y - top - pinchState.anchorPoint.y * nextScale
			suppressCanvasClick = true
			suppressCanvasDoubleClick = true

		resetTouchTap = ->
			touchTapCandidateNode = null
			touchTapStartPoint = null
			touchTapMoved = false

		installTouchHandlers = ->
			touchCanvas = getSvgElement()
			return if not touchCanvas

			touchStartHandler = (event) ->
				if event.touches?.length >= 2
					event.preventDefault()
					$scope.$evalAsync(-> beginPinch(event))
					resetTouchTap()
					return

				touchTapCandidateNode = getEventNode(event.target)
				touchTapStartPoint = getTouchClientPoint(event)
				touchTapMoved = false

				if isBackgroundTarget(event.target)
					$scope.$evalAsync(-> startPan(touchTapStartPoint))
					return

				return if $scope.net.getActiveTool().name isnt "Arrows"
				node = getEventNode(event.target)
				return if not node
				event.preventDefault()
				$scope.$evalAsync(-> $scope.mouseDownOnNode(node, event))

			touchMoveHandler = (event) ->
				if event.touches?.length >= 2 or pinchState
					event.preventDefault()
					$scope.$evalAsync ->
						beginPinch(event) if not pinchState
						updatePinch(event)
					return

				currentPoint = getTouchClientPoint(event)
				if touchTapStartPoint and currentPoint
					deltaX = currentPoint.x - touchTapStartPoint.x
					deltaY = currentPoint.y - touchTapStartPoint.y
					touchTapMoved = true if Math.sqrt(deltaX * deltaX + deltaY * deltaY) > tapMoveThreshold

				if panState.active
					event.preventDefault()
					$scope.$evalAsync(-> updatePan(currentPoint))
					return

				return if $scope.net.getActiveTool().name isnt "Arrows"
				return if not mouseDownNode
				event.preventDefault()
				$scope.$evalAsync(-> $scope.mouseMoveOnCanvas(event))

			touchEndHandler = (event) ->
				if pinchState
					if event.touches?.length >= 2
						event.preventDefault()
						$scope.$evalAsync(-> updatePinch(event))
						return
					pinchState = null
					resetTouchTap()
					return

				targetNode = getEventNode(getTouchTarget(event))
				activeTool = $scope.net.getActiveTool()

				if activeTool.name is "Arrows" and mouseDownNode
					event.preventDefault()
					$scope.$evalAsync ->
						if targetNode
							$scope.mouseUpOnNode(targetNode, event)
						else
							$scope.mouseUpOnCanvas(event)
					resetTouchTap()
					return

				if panState.active
					event.preventDefault() if finishPan()
					lastTouchTapNode = null
					lastTouchTapAt = 0
					resetTouchTap()
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

				resetTouchTap()

			touchCanvas.addEventListener('touchstart', touchStartHandler, {passive: false})
			touchCanvas.addEventListener('touchmove', touchMoveHandler, {passive: false})
			touchCanvas.addEventListener('touchend', touchEndHandler, {passive: false})
			touchCanvas.addEventListener('touchcancel', touchEndHandler, {passive: false})

		installWheelHandler = ->
			touchCanvas = getSvgElement()
			return if not touchCanvas

			wheelHandler = (event) ->
				return if isZoomControlTarget(event.target)
				deltaX = normalizeWheelValue(event.deltaX ? 0, event, wheelPanFactor)
				deltaY = normalizeWheelValue(event.deltaY ? 0, event, wheelPanFactor)
				clientPoint = {x: event.clientX, y: event.clientY}

				event.preventDefault()
				$scope.$evalAsync ->
					if event.ctrlKey
						zoomFactor = Math.pow(trackpadZoomFactor, -(event.deltaY ? 0))
						applyZoom($scope.viewport.scale * zoomFactor, clientPoint)
					else if isLikelyTrackpadWheel(event)
						$scope.viewport.panBy(-deltaX, -deltaY)
					else
						zoomSteps = getMouseWheelZoomSteps(event)
						zoomFactor = Math.pow(mouseWheelZoomFactor, -zoomSteps)
						applyZoom($scope.viewport.scale * zoomFactor, clientPoint)

			touchCanvas.addEventListener('wheel', wheelHandler, {passive: false})

		stopEvent = (event) ->
			return if not event
			event.preventDefault()
			event.stopPropagation()

		$scope.zoomIn = (event) ->
			stopEvent(event)
			animateZoomByFactor(zoomButtonFactor)

		$scope.zoomOut = (event) ->
			stopEvent(event)
			animateZoomByFactor(1 / zoomButtonFactor)

		$scope.clickOnCanvas = (event) ->
			if suppressCanvasClick
				suppressCanvasClick = false
				return
			return if mouseDownNode or mouseDownEdge
			$scope.net.getActiveTool().clickOnCanvas($scope.net, getPoint(event), getDragLine(), formDialogService, restart, converterService)

		$scope.dblClickOnCanvas = (event) ->
			if suppressCanvasDoubleClick
				suppressCanvasDoubleClick = false
				return
			return if mouseDownNode or mouseDownEdge
			$scope.net.getActiveTool().dblClickOnCanvas($scope.net, getPoint(event), getDragLine(), formDialogService, restart, converterService)

		$scope.mouseDownOnCanvas = (event) ->
			return if mouseDownNode or mouseDownEdge
			if isBackgroundTarget(event.target)
				startPan(getClientPoint(event))
				return
			$scope.net.getActiveTool().mouseDownOnCanvas($scope.net, getPoint(event), getDragLine(), formDialogService, restart, converterService)

		$scope.mouseMoveOnCanvas = (event) ->
			if panState.active
				updatePan(getClientPoint(event))
				return
			return if not mouseDownNode
			point = getDragTargetPoint(event)
			renderDragPreview(point, snapTargetNode)

		$scope.mouseUpOnCanvas = (event) ->
			if panState.active
				finishPan()
				return
			activeTool = $scope.net.getActiveTool()
			if mouseDownNode and snapTargetNode and activeTool.name is "Arrows"
				activeTool.mouseUpOnNode($scope.net, snapTargetNode, mouseDownNode, getDragLine(), formDialogService, restart, converterService)
			else if mouseDownNode
				clearDragLine()
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
		$timeout(installWheelHandler)

		$scope.$on '$destroy', ->
			window.removeEventListener('resize', resize)
			cancelZoomAnimation()

			return if not touchCanvas
			touchCanvas.removeEventListener('touchstart', touchStartHandler, {passive: false}) if touchStartHandler
			touchCanvas.removeEventListener('touchmove', touchMoveHandler, {passive: false}) if touchMoveHandler
			touchCanvas.removeEventListener('touchend', touchEndHandler, {passive: false}) if touchEndHandler
			touchCanvas.removeEventListener('touchcancel', touchEndHandler, {passive: false}) if touchEndHandler
			touchCanvas.removeEventListener('wheel', wheelHandler, {passive: false}) if wheelHandler


class EditorCanvas extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/editorCanvas.html"
			controller: EditorCanvasController
		}
