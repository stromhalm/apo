class Draggable extends Directive
	constructor: ->

		return {
			restrict: 'A'
			scope: {
				node: '=draggable'
				net: '=net'
			},
			link: ($scope, element) ->

				# Bind / unbind d3 simulation drag
				$scope.$watch 'net.activeTool', ->
					if $scope.net.getActiveTool().draggable
						$scope.draggableNode = d3.selectAll(element)
							.datum($scope.node)
							.call($scope.net.simulation.drag())
					else if $scope.draggableNode
						$scope.draggableNode.on('mousedown.drag', null)
						$scope.draggableNode.on('touchstart.drag', null)
		}