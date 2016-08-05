class SidenavController extends Controller
	constructor: ($mdSidenav, $state, $stateParams, NetStorage, $mdDialog) ->

		@newName = ""

		@toggleSideMenu = ->
			$mdSidenav("left-menu").toggle()

		@isNet = (net) ->
			$state.is "editor", name: net.name

		@goToNet = (net) ->
			$state.go "editor", name: net.name
			$mdSidenav("left-menu").close()

		@nameValidation = (name) ->
			return "\" is not allowed" if name.replace("\"", "") isnt name
			return "A net with this name already exists" if NetStorage.getNetByName(name)
			return true

		@createNewNet = (name, type, $event) ->
			if (!name or !type or @nameValidation(name) isnt true)
			else
				if type is "PN" then success = NetStorage.addNet(new PetriNet({name: name}))
				else if type is "LTS" then success = NetStorage.addNet(new TransitionSystem({name: name}))
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
					$state.go "editor", name: NetStorage.getNets()[0].name

		# load all nets, direct acess to storage for 2-way-binding
		@nets = NetStorage.storageObjects

		# Get selected net from storage
		net = NetStorage.getNetByName(decodeURI($stateParams.name))


class Sidenav extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/sidenav.html"
			controller: SidenavController
			controllerAs: "sn"
		}
