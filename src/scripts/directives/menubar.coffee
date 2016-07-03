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

		@showAPT = (net, $event) ->
			dialog = $mdDialog.prompt
				templateUrl: "/views/directives/aptExport.html"
				controller: AptExportController
				controllerAs: "ae"
				clickOutsideToClose: true
				fullscreen: true
				targetEvent: $event # To animate the dialog to/from the click
				locals:
					net: net
			$mdDialog.show(dialog)

		@importAPT = ($event) ->
			dialog = $mdDialog.prompt
				templateUrl: "/views/directives/aptImport.html"
				controller: AptImportController
				controllerAs: "ai"
				clickOutsideToClose: true
				fullscreen: true
				targetEvent: $event # To animate the dialog to/from the click
			$mdDialog.show(dialog)


class AptExportController extends Controller
	constructor: ($mdDialog, converterService) ->

		@aptCode = converterService.getAptFromNet(@net)

		@closeDialog = -> $mdDialog.hide()

		@download = ->
			element = document.createElement('a')
			element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(@aptCode))
			element.setAttribute('target', '_blank')
			element.setAttribute('download', @net.name + ".apt")
			element.style.display = 'none'
			document.body.appendChild(element)
			element.click()
			document.body.removeChild(element)


class AptImportController extends Controller
	constructor: ($mdDialog, converterService, NetStorage) ->

		@closeDialog = -> $mdDialog.hide()

		@import = ->
			@errorMsg = ""
			net = converterService.getNetFromApt(@aptCode)
			if not net
				$mdDialog.show(
					$mdDialog.alert
						title: "Syntax Error"
						textContent: "Couldn't import the net beacause of syntax errors in the apt code"
						ok: "OK"
				)
			else
				success = NetStorage.addNet(net)
				if not success
					$mdDialog.show(
						$mdDialog.alert
							title: "Name exists"
							textContent: "A net with the name '#{net.name}' already exists"
							ok: "OK"
					)
				else
					@closeDialog()


class Menubar extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/menubar.html"
			controller: MenubarController
			controllerAs: "mb"
		}
