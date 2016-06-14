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

		@createNewNet = (name, type, $event) ->
			if (!name or !type)
			else
				if type="PN" then success = NetStorage.addPetriNet(name)
				else if type="LTS" then success = NetStorage.addTransitionSystem(name)
				if not success
					alert = $mdDialog.alert
						title: "Can Not Create Net"
						textContent: "A net with the name '#{name}' already exists!"
						ok: "OK"
						targetEvent: $event # To animate the dialog to/from the click
					$mdDialog.show(alert).finally ->
						alert = undefined
				@newName = ""
				@newType = ""

		@deleteNet = (net, $event) ->
			prompt = $mdDialog.confirm
				title: "Delete Net"
				textContent: "Do you really want to delete the net '#{net.name}'?"
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
