class Draggable extends Directive
	constructor: ->

		return {
			restrict: 'A'
			scope: {
				node: '=draggable'
				net: '=net'
				viewport: '=viewport'
			},
			link: ($scope, element) ->
				dragPointerOffset = null

				suppressTouchScroll = (event) ->
					event.preventDefault()

				getActiveTool = ->
					return null if typeof $scope.net?.getActiveTool isnt 'function'
					$scope.net.getActiveTool()

				getSourceClientPoint = ->
					sourceEvent = d3.event?.sourceEvent
					return null if not sourceEvent
					touch = sourceEvent.touches?[0] or sourceEvent.changedTouches?[0]
					clientX = touch?.clientX ? sourceEvent.clientX
					clientY = touch?.clientY ? sourceEvent.clientY
					return null if not isFinite(clientX) or not isFinite(clientY)
					{x: clientX, y: clientY}

				captureDragPointerOffset = (node) ->
					return if typeof $scope.viewport?.getCanvasPoint isnt 'function'
					clientPoint = getSourceClientPoint()
					return if not clientPoint

					svgRect = element[0].closest?('svg')?.getBoundingClientRect?()
					point = $scope.viewport.getCanvasPoint(clientPoint.x, clientPoint.y, svgRect)
					dragPointerOffset =
						x: node.x - point.x
						y: node.y - point.y

				syncNodeToPointer = (node) ->
					return if typeof $scope.viewport?.getCanvasPoint isnt 'function'
					clientPoint = getSourceClientPoint()
					return if not clientPoint

					svgRect = element[0].closest?('svg')?.getBoundingClientRect?()
					point = $scope.viewport.getCanvasPoint(clientPoint.x, clientPoint.y, svgRect)
					offsetX = dragPointerOffset?.x ? 0
					offsetY = dragPointerOffset?.y ? 0
					node.x = point.x + offsetX
					node.y = point.y + offsetY
					node.px = node.x
					node.py = node.y

				unbindDrag = ->
					dragPointerOffset = null
					if $scope.draggableNode
						$scope.draggableNode.on('.drag', null)
					element[0].removeEventListener('touchmove', suppressTouchScroll, {passive: false})

				bindDrag = ->
					return unbindDrag() if typeof $scope.net?.simulation?.drag isnt 'function'

					dragBehavior = $scope.net.simulation.drag()
						.on 'dragstart.codex', (node) ->
							sourceType = d3.event?.sourceEvent?.type ? ''
							activeTool = getActiveTool()
							if sourceType.indexOf('touch') is 0 and activeTool
								activeTool.mouseDownOnNode($scope.net, node)
							captureDragPointerOffset(node)
							syncNodeToPointer(node)
							d3.event?.sourceEvent?.preventDefault?()
						.on 'drag.codex', (node) ->
							syncNodeToPointer(node)
							d3.event?.sourceEvent?.preventDefault?()
						.on 'dragend.codex', ->
							dragPointerOffset = null

					$scope.draggableNode = d3.select(element[0])
						.datum($scope.node)
						.on('.drag', null)
						.call(dragBehavior)

				# Bind / unbind d3 simulation drag
				$scope.$watch 'net.activeTool', ->
					activeTool = getActiveTool()
					if activeTool?.draggable
						bindDrag()
						element[0].addEventListener('touchmove', suppressTouchScroll, {passive: false})
					else
						unbindDrag()
		}
