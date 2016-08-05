class MenubarController extends Controller
	constructor: ($mdDialog, NetStorage, $state, apt, $http, formDialogService, converterService, $timeout) ->

		@createNet = ($event, type) ->
			formDialogService.runDialog({
				title: "Create #{type}"
				text: "Enter a name for the new #{type}."
				event: $event
				formElements: [{
					type: "text"
					name: "Name"
					validation: (value) ->
						return "The name can't contain \"" if value and value.replace("\"", "") isnt value
						return "A net with this name already exists" if value and NetStorage.getNetByName(value)
						return true
				}]
			})
			.then (formElements) ->
				if formElements
					switch type
						when "petri net" then newNet = new PetriNet({name: formElements[0].value})
						else newNet = new TransitionSystem({name: formElements[0].value})
					NetStorage.addNet(newNet)

		@renameNet = (oldName, $event) ->
			formDialogService.runDialog({
				title: "Rename Net"
				text: "Enter a new name for the net."
				event: $event
				formElements: [{
					type: "text"
					name: "New Name"
					value: oldName
					validation: (value) ->
						return "The name can't contain \"" if value and value.replace("\"", "") isnt value
						return "A net with this name already exists" if value and NetStorage.getNetByName(value)
						return true
				}]
			})
			.then (formElements) ->
				if formElements
					newName = formElements[0].value
					NetStorage.renameNet(oldName, newName)
					$state.go "editor", name: newName

		@showAPT = (net, $event) ->
			formDialogService.runDialog({
				title: "APT Export"
				ok: "download"
				cancel: false
				event: $event
				outputElements: [
					{
						type: "code"
						name: "Generated Code"
						value: converterService.getAptFromNet(net)
					}
				]
				onComplete: () ->
					element = document.createElement('a')
					element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(converterService.getAptFromNet(net)))
					element.setAttribute('target', '_blank')
					element.setAttribute('download', net.name + ".apt")
					element.style.display = 'none'
					document.body.appendChild(element)
					element.click()
					document.body.removeChild(element)
					return false # do not close dialog after download
			})

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
						validation: (value) ->
							return "A net with this name already exists" if value and NetStorage.getNetByName(value.split(".name \"")[1].split("\"")[0])
							return true
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
								textContent: "Couldn't import the net because of syntax errors in the apt code"
								ok: "OK"
						)
					else
						NetStorage.addNet(net)

		@startAnalyzer = (analyzer, net) ->
			analyzer.run(apt, NetStorage, converterService, net)

class Menubar extends Directive
	constructor: ->
		return {
			templateUrl: "/views/directives/menubar.html"
			controller: MenubarController
			controllerAs: "mb"
		}
