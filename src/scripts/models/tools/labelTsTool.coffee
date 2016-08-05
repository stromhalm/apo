class @LabelTsTool extends @Tool
	constructor: () ->
		super()
		@name = "Labels"
		@icon = "text_fields"

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
				validation: (value) -> if value is "" then true else false
		})
		if mouseDownEdge.right >= 1
			formElements.push({
				name: "#{sourceObj.getText()} → #{targetObj.getText()}"
				type: "textArray"
				value: mouseDownEdge.labelsRight
				validation: (value) -> if value is "" then true else false
			})

		if formElements.length is 1
			labelText = "a label"
		else
			labelText = "labels"

		formDialogService.runDialog({
			title: "Set Label"
			text: "Enter #{labelText} for this edge"
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
			title: "Label for Node"
			text: "Enter a name for this #{mouseDownNode.type}"
			formElements: [
				{
					name: "Name"
					type: "text"
					value: nodeObj.getText()
					validation: @labelValidator
				}
			]
		})
		.then (formElements) ->
			if formElements
				mouseDownNode.label = formElements[0].value
				restart()
