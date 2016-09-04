class Fileread extends Directive
	constructor: ->
		return {
			restrict: 'A'
			scope: {
				fileread: "="
				onfileload: "=?"
			},
			link: (scope, element, attributes) ->
				element.bind("change", (changeEvent) ->
					reader = new FileReader()
					reader.onload = (loadEvent) ->
						scope.$apply( ->
							scope.fileread = loadEvent.target.result
							scope.onfileload(loadEvent.target.result) if scope.onfileload
						)
					reader.readAsText(changeEvent.target.files[0])
				)
		}
