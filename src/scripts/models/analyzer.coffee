###
	This is an abstract class for nets analyzers.
###

class @Analyzer
	constructor: () ->
		@name = ""
		@icon = "help_outline"
		@description = ""
		@ok = "generate"
		@cancel = "close"
		@offlineCapable = false

	run: (apt, NetStorage, converterService, currentNet, formDialogService, event, internetConnection) ->
		analyzer = @analyze
		formElements = @inputOptions(currentNet, NetStorage)
		outputElements = []
		@staticError = @initialError
		if not @offlineCapable and not internetConnection
			@staticError = -> "Couldn't connect to server!"

		formDialogService.runDialog
			title: @name
			text: @description
			ok: @ok
			cancel: @cancel
			event: event
			staticError: @staticError
			net: currentNet
			formElements: formElements
			outputElements: outputElements
			onComplete: (inputOptions) ->
				analyzer(inputOptions, outputElements, currentNet, apt, converterService, NetStorage, formDialogService)

	initialError: (currentNet) -> false
	inputOptions: (currentNet, NetStorage) ->
	analyze: (inputOptions, apt, currentNet, converterService, NetStorage) ->
