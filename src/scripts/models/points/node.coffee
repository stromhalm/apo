class @Node extends @Point
	constructor: (options = false) ->
		{@id = false, @label = ""} = options
		super(options)
		@shape = 'circle'
		@radius = 18
		@labelXoffset = 0
		@labelYoffset = 4

	setId: (@id) ->

	getText: ->
		return @label if @label
		return @id

	getTokenLabel: -> ""
