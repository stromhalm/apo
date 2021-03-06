###
	The coverability analyzer can generate the petri nets coverability graph via angular-apt.
###

class @ExamineLts extends @Analyzer
	constructor: () ->
		super()
		@icon = "playlist_add_check"
		@name = "Transition System Analysis"
		@description =  "Perform various tests on a transition systems at once."
		@ok = "Start Tests"

	# this module needs an initial state
	initialError: (currentNet) ->
		return "No inital state specified!" if not currentNet.getInitState()
		return false

	# connect to angular-apt
	analyze: (inputOptions, outputElements, currentNet, apt, converterService, netStorageService, formDialogService) ->
		aptNet = converterService.getAptFromNet(currentNet)
		apt.examineLts(aptNet).then (response) ->
			outputElements.splice(0) while outputElements.length > 0 # clear outputElements
			for test, result of response.data
				result = "Yes" if result is true
				result = "No" if result is false
				outputElements.push(
					{
						name: test
						value: result
						type: "text"
						flex: 20
					}
				)
		return false # do not close imediatly
