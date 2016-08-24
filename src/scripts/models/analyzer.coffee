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

	run: (apt, NetStorage, converterService, currentNet, formDialogService, event) ->
		analyzer = @analyze
		formElements = @inputOptions(currentNet, NetStorage)
		outputElements = []
		formDialogService.runDialog
			title: @name
			text: @description
			ok: @ok
			cancel: @cancel
			event: event
			formElements: formElements
			outputElements: outputElements
			onComplete: (inputOptions) ->
				analyzer(inputOptions, outputElements, currentNet, apt, converterService, NetStorage, formDialogService)

	inputOptions: (currentNet, NetStorage) ->
	analyze: (inputOptions, apt, currentNet, converterService, NetStorage) ->
