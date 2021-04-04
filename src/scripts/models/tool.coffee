###
	This is an abstract class for all editor tools.
	ngStorage can't save circle references,
	therefore we can't save the net reference – it has to be passed with every function call
###

class @Tool
	constructor: ->
		@icon = "help_outline"
		@draggable = false
		@name = "Unnamed Tool"
		@description = ""

	clickOnNode: (net, node) ->
	dblClickOnNode: (net, node) ->
	mouseDownOnNode: (net, node) ->
	mouseUpOnNode: (net, node) ->

	clickOnEdge: (net, edge) ->
	dblClickOnEdge: (net, edge) ->
	mouseDownOnEdge: (net, edge) ->
	mouseUpOnEdge: (net, edge) ->

	clickOnCanvas: (net, event) ->
	dblClickOnCanvas: (net, event) ->
	mouseDownOnCanvas: (net, event) ->
	mouseUpOnCanvas: (net, event) ->

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
