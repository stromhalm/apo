class @LabelPnTool extends @Tool
	constructor: ->
		super()
		@name = "Labels"
		@icon = "text_fields"

	mouseDownOnEdge: (net, mouseDownEdge, $mdDialog, restart, converterService) ->

		getPrompt = (source, target) ->
			sourceObj = converterService.getNodeFromData(source)
			targetObj = converterService.getNodeFromData(target)
			$mdDialog.prompt
				title: "Set Weight"
				textContent: "Enter a weight for the edge '#{sourceObj.getText()} → #{targetObj.getText()}'"
				ok: "OK"
				cancel: "Cancel"

		if mouseDownEdge.left >= 1
			$mdDialog.show(getPrompt(mouseDownEdge.target, mouseDownEdge.source))
			.then (leftWeight) ->
				mouseDownEdge.left = leftWeight
				restart()
				if mouseDownEdge.right >= 1
					$mdDialog.show(getPrompt(mouseDownEdge.source, mouseDownEdge.target))
					.then (rightWeight) ->
						mouseDownEdge.right = rightWeight
						restart()

		else if mouseDownEdge.right >= 1
			$mdDialog.show(getPrompt(mouseDownEdge.source, mouseDownEdge.target))
			.then (rightWeight) ->
				mouseDownEdge.right = rightWeight
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
