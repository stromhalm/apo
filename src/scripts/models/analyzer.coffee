class @Analyzer
	constructor: () ->
		@name = ""
		@icon = "help_outline"
		@description = ""
		@ok = "generate"

	run: (apt, NetStorage, converterService, currentNet, formDialogService, $event) ->
		analyzer = @analyze
		formDialogService.runDialog
			title: @name
			text: @description
			ok: @ok
			event: $event
			formElements: @inputOptions(currentNet, NetStorage)
		.then (inputOptions) ->
			analyzer(inputOptions, apt, currentNet, converterService, NetStorage) if (inputOptions)

	inputOptions: (currentNet, NetStorage) ->
	analyze: (inputOptions, apt, currentNet, converterService, NetStorage) ->
