###
	This tool sets the number of tokens on places and fires transitions in petri nets.
###

class @TokenTool extends @Tool
	constructor: ->
		super()
		@name = "Tokens"
		@description = "Set the number of tokens on places and fire transitions"
		@icon = "play_circle_outline"

	clickOnNode: (net, node, dragLine, formDialogService, restart) ->

		if node.type is "place"
			formDialogService.runDialog({
				title: "Set Tokens"
				text: "Enter a number of tokens for this place"
				formElements: [
					{
						name: "Integer ≥ 0"
						type: "number"
						min: 0
						value: parseInt(node.tokens)
					}
				]
			})
			.then (formElements) ->
				if formElements
					tokens = formElements[0].value
					if tokens >= 0
						node.tokens = tokens
						restart()

		else if node.type is "transition"
			net.fireTransition(node)
