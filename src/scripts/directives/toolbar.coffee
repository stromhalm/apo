###
	This is the toolbar directive. Due to little functionality it has no controller.
	All its logic is in the template.
###

class Toolbar extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/toolbar.html"
		}
