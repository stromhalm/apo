class @Node extends @Point
	constructor: (options) ->
		{@reflexive, @id} = options
		super(options.x, options.y)
		@shape = 'circle'
		@radius = 18

	setId: (@id) ->

	getText: -> @id
