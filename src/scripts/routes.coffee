`angular.module('app').config(function($stateProvider, $urlRouterProvider, $locationProvider) {

   $locationProvider.html5Mode(false).hashPrefix('!');
   $urlRouterProvider.otherwise('/0');
   $stateProvider
      .state('editor', {
         url: "/:name",
         templateUrl: "views/directives/editor.html",
         controller: "EditorController"
      });
});`


###
class Config
	constructor: ($routeProvider) ->
		$routeProvider
		.when '/github/:id',
			controller: 'gitHubController'
		.otherwise
			redirectTo: '/github'

angular.module('app').config ['$routeProvider', Config]
###
