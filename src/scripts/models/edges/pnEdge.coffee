class @PnEdge extends @Edge
	constructor: (options)->
		{@weight} = options
		@type = "pnEdge"
		super(options)

	getText: -> @weight
