class ToolbarController extends Controller


class Toolbar extends Directive
	constructor: ->
		return {
			controller: ToolbarController
			controllerAs: "tb"
			templateUrl: "/views/directives/toolbar.html"
		}
