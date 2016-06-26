class @LabelTsTool extends @Tool
	constructor: ->
		@name = "Labels"
		@icon = "text_fields"

	mouseDownOnEdge: (net, mouseDownEdge, $mdDialog, restart, NetStorage) ->
		return if mouseDownEdge.type is "tsInitEdge"
		
		getPrompt = (source, target) ->
			sourceObj = NetStorage.getNodeFromData(source)
			targetObj = NetStorage.getNodeFromData(target)
			$mdDialog.prompt
				title: "Set Label"
				textContent: "Enter name for the edge '#{sourceObj.getText()} → #{targetObj.getText()}'"
				ok: "OK"
				cancel: "Cancel"

		if mouseDownEdge.left >= 1
			$mdDialog.show(getPrompt(mouseDownEdge.target, mouseDownEdge.source))
			.then (labelLeft) ->
				mouseDownEdge.labelLeft = labelLeft
				restart()
				if mouseDownEdge.right >= 1
					$mdDialog.show(getPrompt(mouseDownEdge.source, mouseDownEdge.target))
					.then (labelRight) ->
						mouseDownEdge.labelRight = labelRight
						restart()

		else if mouseDownEdge.right >= 1
			$mdDialog.show(getPrompt(mouseDownEdge.source, mouseDownEdge.target))
			.then (labelRight) ->
				mouseDownEdge.labelRight = labelRight
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
