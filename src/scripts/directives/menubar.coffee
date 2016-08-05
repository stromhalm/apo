class MenubarController extends Controller
	constructor: ($mdDialog, NetStorage, $state, apt, $http, formDialogService, converterService) ->

		createNet = ($event, type, nameExists = false) ->
			if nameExists then alert = "A net with the name '#{nameExists}' already exists. " else alert = ""
			formDialogService.runDialog({
				title: "Create #{type}"
				text: alert + "Enter a name for the new #{type}."
				event: $event
				formElements: [{
					type: "text"
					name: "Name"
					validation: (value) ->
						return "A net with this name already exists" if NetStorage.getNetByName(value)
						return true
				}]
			})
			.then (formElements) ->
				if formElements
					switch type
						when "petri net" then newNet = new PetriNet({name: formElements[0].value})
						else newNet = new TransitionSystem({name: formElements[0].value})
					success = NetStorage.addNet(newNet)
					createNet($event, type, newNet.name) if not success
		@createNet = createNet

		renameNet = (oldName, $event, nameExists = false) ->
			if nameExists then alert = "A net with the name '#{nameExists}' already exists. " else alert = ""
			formDialogService.runDialog({
				title: "Rename Net"
				text: alert + "Enter a new name for the net."
				event: $event
				formElements: [{
					type: "text"
					name: "New Name"
					value: oldName
				}]
			})
			.then (formElements) ->
				if formElements
					newName = formElements[0].value
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
			formDialogService.runDialog({
				title: "APT Import"
				text: "Insert APT code here to import a net"
				ok: "import"
				event: $event
				formElements: [
					{
						type: "code"
						name: "Insert Code"
					}
				]
			})
			.then (formElements) ->
				if formElements
					net = converterService.getNetFromApt(formElements[0].value)
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

		@startAnalyzer = (analyzer, net) ->
			analyzer.run(apt, NetStorage, converterService, net)


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

class Menubar extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/menubar.html"
			controller: MenubarController
			controllerAs: "mb"
		}
