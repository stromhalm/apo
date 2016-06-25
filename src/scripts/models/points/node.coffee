class @Node extends @Point
	constructor: (options) ->
		{@id, @label = ""} = options
		super(options.x, options.y)
		@shape = 'circle'
		@radius = 18
		@labelXoffset = 0
		@labelYoffset = 4

	setId: (@id) ->

	getText: ->
		return @label if @label
		return @id

	getTokenLabel: -> ""
