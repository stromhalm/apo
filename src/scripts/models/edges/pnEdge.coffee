class @PnEdge extends @Edge
	constructor: (options)->
		{@weight = 1} = options
		@type = "pnEdge"
		super(options)

	getText: -> @weight
