class Draggable extends Directive
	constructor: ->

		return {
			restrict: 'A'
			scope: {
				node: '=draggable'
				net: '=net'
			},
			link: ($scope, element) ->
				bindDrag = ->
					$scope.draggableNode = d3.select(element[0])
						.datum($scope.node)
						.on('.drag', null)
						.call($scope.net.simulation.drag())

				# Bind / unbind d3 simulation drag
				$scope.$watch 'net.activeTool', ->
					if $scope.net.getActiveTool().draggable
						bindDrag()
					else if $scope.draggableNode
						$scope.draggableNode.on('.drag', null)
		}
