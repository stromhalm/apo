class SidenavController extends Controller
	constructor: ($mdSidenav, $state, $mdDialog, NetStorage) ->

		@toggleSideMenu = ->
			$mdSidenav("left-menu").toggle()

		@isNet = (net) ->
			$state.is "editor", name: net.name

		@goToNet = (net) ->
			$state.go "editor", name: net.name
			$mdSidenav("left-menu").close()

		@createNewNet = (name, $event) ->
			if (!name)
			else if NetStorage.addTransitionSystem(name) == false
				alert = $mdDialog.alert
					title: "Can Not Create Transition System"
					textContent: "A transition system with the name #{name} already exists!"
					ok: "OK"
					targetEvent: $event # To animate the dialog to/from the click
				$mdDialog.show(alert).finally ->
					alert = undefined
			@newName = ""

		@deleteNet = (id, $event) ->
			prompt = $mdDialog.confirm
				title: "Delete Petri Net"
				textContent: "Do you really want to delete the petri net '#{@nets[id].name}'?"
				ok: "Delete"
				cancel: "Cancel"
				targetEvent: $event # To animate the dialog to/from the click

			prompt = $mdDialog.show(prompt)
			.finally ->
				prompt = undefined
			.then ->
				NetStorage.deleteNet(id)
		@nets = NetStorage.getNets()


class Sidenav extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/sidenav.html"
			controller: SidenavController
			controllerAs: "sn"
		}
