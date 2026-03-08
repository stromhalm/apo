class Draggable extends Directive
	constructor: ->

		return {
			restrict: 'A'
			scope: {
				node: '=draggable'
				net: '=net'
			},
			link: ($scope, element) ->
				suppressTouchScroll = (event) ->
					event.preventDefault()

				getActiveTool = ->
					return null if typeof $scope.net?.getActiveTool isnt 'function'
					$scope.net.getActiveTool()

				unbindDrag = ->
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
							d3.event?.sourceEvent?.preventDefault?()
						.on 'drag.codex', ->
							d3.event?.sourceEvent?.preventDefault?()

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
