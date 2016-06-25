class @LabelPnTool extends @Tool
	constructor: ->
		@name = "Labels"
		@icon = "text_fields"

	mouseDownOnEdge: (net, mouseDownEdge, $mdDialog, restart) ->
		prompt = $mdDialog.prompt
			title: "Set Weight"
			textContent: "Enter a weight for this edge"
			ok: "OK"
			cancel: "Cancel"
		$mdDialog.show(prompt)
		.then (weight) ->
			mouseDownEdge.weight = weight
			restart()

	mouseDownOnNode: (net, mouseDownNode, dragLine, $mdDialog, restart) ->
		prompt = $mdDialog.prompt
			title: "Label for Node"
			textContent: "Enter a name for this #{mouseDownNode.type}"
			ok: "OK"
			cancel: "Cancel"
		$mdDialog.show(prompt)
		.then (label) ->
			mouseDownNode.label = label
			restart()
