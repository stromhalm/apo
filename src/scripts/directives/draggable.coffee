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

				bindDrag = ->
					dragBehavior = $scope.net.simulation.drag()
						.on 'dragstart.codex', (node) ->
							sourceType = d3.event?.sourceEvent?.type ? ''
							if sourceType.indexOf('touch') is 0
								$scope.net.getActiveTool().mouseDownOnNode($scope.net, node)
							d3.event?.sourceEvent?.preventDefault?()
						.on 'drag.codex', ->
							d3.event?.sourceEvent?.preventDefault?()

					$scope.draggableNode = d3.select(element[0])
						.datum($scope.node)
						.on('.drag', null)
						.call(dragBehavior)

				# Bind / unbind d3 simulation drag
				$scope.$watch 'net.activeTool', ->
					if $scope.net.getActiveTool().draggable
						bindDrag()
						element[0].addEventListener('touchmove', suppressTouchScroll, {passive: false})
					else if $scope.draggableNode
						$scope.draggableNode.on('.drag', null)
						element[0].removeEventListener('touchmove', suppressTouchScroll, {passive: false})
		}
