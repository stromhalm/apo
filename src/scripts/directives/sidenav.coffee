class SidenavController extends Controller
	constructor: ($mdSidenav, $state, $stateParams, $mdDialog, NetStorage) ->

		# load all nets, direct acess to storage for 2-way-binding
		@nets = NetStorage.storageObjects

		# Get selected net from storage
		net = NetStorage.getNetByName(decodeURI($stateParams.name))

		# Go to first net if not found
		if not net
			$state.go 'editor', name: NetStorage.getNets()[0].name

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
					textContent: "A transition system with the name '#{name}' already exists!"
					ok: "OK"
					targetEvent: $event # To animate the dialog to/from the click
				$mdDialog.show(alert).finally ->
					alert = undefined
			@newName = ""

		@deleteNet = (net, $event) ->
			prompt = $mdDialog.confirm
				title: "Delete Petri Net"
				textContent: "Do you really want to delete the petri net '#{net.name}'?"
				ok: "Delete"
				cancel: "Cancel"
				targetEvent: $event # To animate the dialog to/from the click
			prompt = $mdDialog.show(prompt)
			.finally ->
				prompt = undefined
			.then ->
				NetStorage.deleteNet(net.name)
				# Go to first net if current net has been deleted
				if net.name is decodeURI($stateParams.name)
					$state.go 'editor', name: NetStorage.getNets()[0].name


class Sidenav extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/sidenav.html"
			controller: SidenavController
			controllerAs: "sn"
		}
