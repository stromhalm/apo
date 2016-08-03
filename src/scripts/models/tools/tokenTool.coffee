class @TokenTool extends @Tool
	constructor: ->
		super()
		@name = "Tokens"
		@icon = "play_circle_outline"

	mouseDownOnNode: (net, mouseDownNode, dragLine, formDialogService, restart) ->

		if mouseDownNode.type is "place"
			formDialogService.runDialog({
				title: "Set Tokens"
				text: "Enter a number of tokens for this place"
				formElements: [
					{
						name: "Integer ≥ 0"
						type: "number"
						min: 0
						value: parseInt(mouseDownNode.token)
					}
				]
			})
			.then (formElements) ->
				if formElements
					tokens = formElements[0].value
					if tokens >= 0
						mouseDownNode.token = tokens
						restart()

		else if mouseDownNode.type is "transition"
			net.fireTransition(mouseDownNode)
