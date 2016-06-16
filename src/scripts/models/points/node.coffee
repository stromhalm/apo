class @Node extends @Point
	constructor: (options) ->
		{@reflexive, @id} = options
		super(options.x, options.y)

	setId: (@id) ->

	getColor: (isSelected = false) -> 'white'

	getStrokeColor: (isSelected = false) -> 'black'

	getText: () -> @id
