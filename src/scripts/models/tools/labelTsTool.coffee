class @LabelTsTool extends @Tool
	constructor: () ->
		super()
		@name = "Labels"
		@icon = "text_fields"
		@description = "Label states and transitions"

	mouseDownOnEdge: (net, mouseDownEdge, formDialogService, restart, converterService) ->
		return if mouseDownEdge.type is "tsInitEdge"

		sourceObj = converterService.getNodeFromData(mouseDownEdge.source)
		targetObj = converterService.getNodeFromData(mouseDownEdge.target)

		formElements = []
		if mouseDownEdge.left >= 1
			formElements.push({
				name: "#{targetObj.getText()} → #{sourceObj.getText()}"
				type: "textArray"
				value: mouseDownEdge.labelsLeft
		})
		if mouseDownEdge.right >= 1
			formElements.push({
				name: "#{sourceObj.getText()} → #{targetObj.getText()}"
				type: "textArray"
				value: mouseDownEdge.labelsRight
			})

		formDialogService.runDialog({
			title: "Set Labels"
			text: "Enter labels for this edge"
			formElements: formElements
		})
		.then (formElements) ->
			if formElements
				if mouseDownEdge.left >= 1
					mouseDownEdge.labelsLeft = formElements[0].value
					if mouseDownEdge.right >= 1
						mouseDownEdge.labelsRight = formElements[1].value
				else if mouseDownEdge.right >= 1
					mouseDownEdge.labelsRight = formElements[0].value
				restart()

	mouseDownOnNode: (net, mouseDownNode, dragLine, formDialogService, restart, converterService) ->

		nodeObj = converterService.getNodeFromData(mouseDownNode)

		formDialogService.runDialog({
			title: "Labels for state"
			text: "Enter a name for this #{mouseDownNode.type}"
			formElements: [
				{
					name: "Label for the state"
					type: "text"
					value: nodeObj.getText()
					validation: @labelValidator
				}
				{
					name: "Labels for arc to the same state"
					type: "textArray"
					value: mouseDownNode.labelsToSelf
				}
			]
		})
		.then (formElements) ->
			if formElements
				mouseDownNode.label = formElements[0].value
				mouseDownNode.labelsToSelf = formElements[1].value
				restart()
