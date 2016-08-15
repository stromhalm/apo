class @Tool
	constructor: ->
		@icon = "help_outline"
		@draggable = false
		@name = "Unnamed Tool"
		@description = ""

	# ngStorage can't save circle references.
	# Therefore we can't save the net reference – is has to be passed with every function call

	mouseDownOnNode: (net, node, dragLine) ->

	mouseUpOnNode: (net, mouseUpNode, mouseDownNode, dragLine) ->

	mouseDownOnEdge: (net, edge) ->

	mouseDownOnCanvas: (net, point, dragLine) ->

	dblClickOnNode: (net, node) ->

	# General validator for APT labels
	labelValidator: (labelName) ->

		@isPartOfString = (searchFor, searchIn) ->
			searchIn.replace(searchFor, "") isnt searchIn

		return "Labels can't contain '*'" if @isPartOfString('*', labelName)
		return "Labels can't contain ','" if @isPartOfString(',', labelName)
		return "Labels can't contain spaces" if @isPartOfString(' ', labelName)
		return "Labels can't contain '{'" if @isPartOfString('{', labelName)
		return "Labels can't contain '}'" if @isPartOfString('}', labelName)
		return true
