###
	The TsInitEdge highlightes the transition systems initial state.
	It has no label.
###

class @TsInitEdge extends @TsEdge
	constructor: (options) ->
		super(options)
		@type = "tsInitEdge"
		@length = 60

	getText: -> ''
