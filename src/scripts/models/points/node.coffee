class @Node extends @Point
	constructor: (options) ->
		{@reflexive, @id, @label = ""} = options
		super(options.x, options.y)
		@shape = 'circle'
		@radius = 18

	setId: (@id) ->

	getText: ->
		return @label if @label
		return @id
