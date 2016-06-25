class @TokenTool extends @Tool
	constructor: ->
		@name = "Token"
		@icon = "play_circle_outline"

	mouseDownOnNode: (net, mouseDownNode, dragLine, $mdDialog, restart) ->
		if mouseDownNode.type is "place"
			prompt = $mdDialog.prompt
				title: "Set Tokens"
				textContent: "Enter a number of tokens for this place"
				placeholder: "Integer ≥ 0"
				ok: "OK"
				cancel: "Cancel"
			$mdDialog.show(prompt)
			.then (token) ->
				token = parseInt(token)
				if token >= 0
					mouseDownNode.token = token
					restart()

		else if mouseDownNode.type is "transition"
			console.log net.fireTransition(mouseDownNode)
