class @LabelTsTool extends @Tool
	constructor: ->
		@name = "Labels"
		@icon = "text_fields"

	mouseDownOnEdge: (net, mouseDownEdge, $mdDialog, restart) ->
		prompt = $mdDialog.prompt
			title: "Label for Edge"
			textContent: "Enter a name for this edge"
			placeholder: "name"
			ok: "OK"
			cancel: "Cancel"
		$mdDialog.show(prompt)
		.then (label) ->
			mouseDownEdge.label = label
			restart()

	mouseDownOnNode: (net, mouseDownNode, dragLine, $mdDialog, restart) ->
		prompt = $mdDialog.prompt
			title: "Label for Node"
			textContent: "Enter a name for this #{mouseDownNode.type}"
			placeholder: "name"
			ok: "OK"
			cancel: "Cancel"
		$mdDialog.show(prompt)
		.then (label) ->
			mouseDownNode.label = label
			restart()
