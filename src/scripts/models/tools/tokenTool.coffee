###
	This tool sets the number of tokens on places and fires transitions in petri nets.
###

class @TokenTool extends @Tool
	constructor: ->
		super()
		@name = "Tokens"
		@description = "Set the number of tokens on places and fire transitions"
		@icon = "play_circle_outline"

	mouseDownOnNode: (net, mouseDownNode, dragLine, formDialogService, restart) ->

		if mouseDownNode.type is "place"
			formDialogService.runDialog({
				title: "Set Tokens"
				text: "Enter a number of tokens for this place"
				formElements: [
					{
						name: "Current tokens"
						type: "number"
						min: 0
						value: parseInt(mouseDownNode.tokens)
					},
					{
						name: "Max tokens"
						type: "number"
						min: 1
						value: parseInt(mouseDownNode.tokensCap)
					}
				]
			})
			.then (formElements) ->
				if formElements
					tokens = formElements[0].value
					cap = formElements[1].value
					if tokens >= 0 or cap >= 1
						mouseDownNode.tokens = tokens
						mouseDownNode.tokensCap = cap
						mouseDownNode.radius = if cap is 255 then 18 else 25
						restart()

		else if mouseDownNode.type is "transition"
			net.fireTransition(mouseDownNode)
