###
	This is the topbar directive and its controller.
	It shows the net's name and a menu with some functionality.
###

class TopbarController extends Controller
	constructor: (NetStorage, $mdDialog) ->

		# Delete all nets. Confirms the reset via dialog
		@resetStorage = (event) ->
			$mdDialog.show $mdDialog.confirm
				title: "Delete All Nets"
				textContent: "Do you really want to delete all nets?"
				ok: "Reset Storage"
				cancel: "Cancel"
				targetEvent: event # To animate the dialog to/from the click
			.then ->
				NetStorage.resetStorage()

class Topbar extends Directive
	constructor: ->
		return {
			controller: TopbarController
			controllerAs: "tb"
			templateUrl: "/views/directives/topbar.html"
		}
