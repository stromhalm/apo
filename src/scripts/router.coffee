###
	The router is used to route URLs to the right net.
	html5Mode can't be used because of internal svg references via element id
###

class Router extends Config

	constructor: ($stateProvider, $urlRouterProvider, $locationProvider) ->
		$locationProvider.html5Mode(false)
		$urlRouterProvider.otherwise("/0")
		$stateProvider.state("editor",
			url: "/:name"
			templateUrl: "views/directives/editor.html"
			controller: "editorController"
		)
