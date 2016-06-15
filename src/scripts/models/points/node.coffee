class @Node extends @Point
	constructor: (@reflexive, point) ->
		super(point.x, point.y)

	setId: (@id) ->
