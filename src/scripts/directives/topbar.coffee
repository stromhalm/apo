###
	This is the topbar directive and its controller.
	It shows the net's name and a menu with some functionality.
###

class TopbarController extends Controller
	constructor: (netStorageService, $mdDialog, formDialogService, $state) ->

		@renameNet = (oldName, event) ->
			formDialogService.runDialog({
				title: "Rename Net"
				text: "Enter a new name for the net."
				event: event
				formElements: [{
					type: "text"
					name: "New Name"
					value: oldName
					validation: (value) ->
						return "The name can't contain \"" if value and value.replace("\"", "") isnt value
						return "A net with this name already exists" if value and value isnt oldName and netStorageService.getNetByName(value)
						return true
				}]
			})
			.then (formElements) ->
				if formElements
					newName = formElements[0].value
					netStorageService.renameNet(oldName, newName)
					$state.go "editor", name: newName

		# Delete all nets. Confirms the reset via dialog
		@resetStorage = (event) ->
			$mdDialog.show $mdDialog.confirm
				title: "Delete All Nets"
				textContent: "Do you really want to delete all nets?"
				ok: "Reset Storage"
				cancel: "Cancel"
				targetEvent: event # To animate the dialog to/from the click
			.then(
				-> netStorageService.resetStorage()
				->
			)
			

		@showAbout = (event) ->
			$mdDialog.show
				targetEvent: event
				templateUrl: 'views/directives/about.html'
				controller: AboutController
				controllerAs: "about"
				clickOutsideToClose: true
				fullscreen: true
				bindToController: true

class Topbar extends Directive
	constructor: ->
		return {
			controller: TopbarController
			controllerAs: "tb"
			templateUrl: "/views/directives/topbar.html"
		}

class AboutController extends Controller
	constructor: ($mdDialog) ->

		@pn = new PetriNet("PetriNet")
		@lts = new TransitionSystem("TransitionSystem")
		@netType = "pn" # Set default list

		@close = -> $mdDialog.hide()
