class @TsEdge extends @Edge
	constructor: (options)->
		{@label = ""} = options
		@type = "tsEdge"
		super(options)

	getText: -> @label
