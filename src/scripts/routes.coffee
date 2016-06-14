class Routes extends Config

	constructor: ($stateProvider, $urlRouterProvider, $locationProvider) ->
		$locationProvider.html5Mode(true).hashPrefix("!")
		$urlRouterProvider.otherwise("/0")
		$stateProvider.state("editor",
			url: "/:name"
			templateUrl: "views/directives/editor.html"
			controller: "editorController"
		)
