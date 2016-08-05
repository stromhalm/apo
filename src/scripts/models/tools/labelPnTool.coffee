class @LabelPnTool extends @Tool
	constructor: ->
		super()
		@name = "Labels"
		@icon = "text_fields"

	mouseDownOnEdge: (net, mouseDownEdge, formDialogService, restart, converterService) ->

		sourceObj = converterService.getNodeFromData(mouseDownEdge.source)
		targetObj = converterService.getNodeFromData(mouseDownEdge.target)

		formElements = []
		if mouseDownEdge.left >= 1
			formElements.push({
				name: "#{targetObj.getText()} → #{sourceObj.getText()}"
				type: "number"
				min: 1
				value: mouseDownEdge.left
			})
		if mouseDownEdge.right >= 1
			formElements.push({
				name: "#{sourceObj.getText()} → #{targetObj.getText()}"
				type: "number"
				min: 1
				value: mouseDownEdge.right
			})

		if formElements.length is 1
			weightText = "a weight"
		else
			weightText = "weights"

		formDialogService.runDialog({
			title: "Set Weight"
			text: "Enter #{weightText} for this edge"
			formElements: formElements
		})
		.then (formElements) ->
			if formElements
				if mouseDownEdge.left >= 1
					mouseDownEdge.left = formElements[0].value
					if mouseDownEdge.right >= 1
						mouseDownEdge.right = formElements[1].value
				else if mouseDownEdge.right >= 1
					mouseDownEdge.right = formElements[0].value
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
