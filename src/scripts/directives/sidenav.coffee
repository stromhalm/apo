###
	This is the sidenav directive and its controller.
	The sidenav is hidden by default on small devices.
###

class SidenavController extends Controller

	constructor: ($mdSidenav, $state, $stateParams, netStorageService, $mdDialog) ->

		@newName = ""

		# Toogle sidenav on small devices
		@toggleSideMenu = ->
			$mdSidenav("left-menu").toggle()

		# The currently aktive net is highlighted in the sidenav
		@isNet = (net) ->
			$state.is "editor", name: net.name

		# Change the currently active net in the editor
		@goToNet = (net) ->
			$state.go "editor", name: net.name
			$mdSidenav("left-menu").close()

		# Validate the name of a new net
		@nameValidation = (name) ->
			return "\" is not allowed" if name.replace("\"", "") isnt name
			return "A net with this name already exists" if netStorageService.getNetByName(name)
			return true

		# Create a new net via the sidenav's form
		@createNewNet = (name, type, event) ->
			if (!name or !type or @nameValidation(name) isnt true)
			else
				if type is "PN" then success = netStorageService.addNet(new PetriNet({name: name}))
				else if type is "LTS" then success = netStorageService.addNet(new TransitionSystem({name: name}))
				@newName = ""
				@newType = ""

		# Delte a net via the sidebar
		@deleteNet = (net, event) ->
			$mdDialog.show $mdDialog.confirm
				title: "Delete Net"
				textContent: "Do you really want to delete the net '#{net.name}'?"
				ok: "Delete"
				cancel: "Cancel"
				targetEvent: event # To animate the dialog to/from the click
			.then ->
				netStorageService.deleteNet(net.name)

		# load all nets, direct acess to storage for 2-way-binding
		@nets = netStorageService.storageObjects

		# Get selected net from storage
		net = netStorageService.getNetByName(decodeURI($stateParams.name))


class Sidenav extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/sidenav.html"
			controller: SidenavController
			controllerAs: "sn"
		}
