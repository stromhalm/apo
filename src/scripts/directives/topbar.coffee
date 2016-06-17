class TopbarController extends Controller
	constructor: (NetStorage) ->

		@resetStorage = ->
			NetStorage.resetStorage()

class Topbar extends Directive
	constructor: ->
		return {
			controller: TopbarController
			controllerAs: "tb"
			templateUrl: '/views/directives/topbar.html'
		}
