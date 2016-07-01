class MenubarController extends Controller
	constructor: ($mdDialog, NetStorage, $state) ->

		createPN = ($event, nameExists = false) ->
			if nameExists then alert = "A net with the name '#{nameExists}' already exists. " else alert = ""
			prompt = $mdDialog.prompt
				title: "Create Petri Net"
				textContent: alert + "Enter a name for the new petri net."
				placeholder: "Enter a name"
				ok: "OK"
				cancel: "Cancel"
				targetEvent: $event # To animate the dialog to/from the click
			$mdDialog.show(prompt)
			.then (pnName) ->
				success = NetStorage.addNet(new PetriNet({name: pnName}))
				createPN($event, pnName) if not success
		@createPN = createPN # required for recursive calls

		createTS = ($event, nameExists = false) ->
			if nameExists then alert = "A net with the name '#{nameExists}' already exists. " else alert = ""
			prompt = $mdDialog.prompt
				title: "Create Transition System"
				textContent: alert + "Enter a name for the new transition system."
				placeholder: "Enter a name"
				ok: "OK"
				cancel: "Cancel"
				targetEvent: $event # To animate the dialog to/from the click
			$mdDialog.show(prompt)
			.then (tsName) ->
				success = NetStorage.addNet(new TransitionSystem({name: tsName}))
				createTS($event, tsName) if not success
		@createTS = createTS # required for recursive calls

		renameNet = (oldName, $event, nameExists = false) ->
			if nameExists then alert = "A net with the name '#{nameExists}' already exists. " else alert = ""
			prompt = $mdDialog.prompt
				title: "Rename net"
				textContent: alert + "Enter a new name for the net."
				placeholder: "Enter a new name"
				ok: "OK"
				cancel: "Cancel"
				targetEvent: $event # To animate the dialog to/from the click
			$mdDialog.show(prompt)
			.then (newName) ->
				success = NetStorage.renameNet(oldName, newName)
				if not success
					renameNet(oldName, $event, newName)
				else
					$state.go "editor", name: newName
		@renameNet = renameNet # required for recursive calls



class Menubar extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/menubar.html"
			controller: MenubarController
			controllerAs: "mb"
		}
