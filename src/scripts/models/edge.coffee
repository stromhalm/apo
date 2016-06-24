class @Edge
	constructor: (options) ->
		{@source, @target, @id, @left = false, @right = false, @length = 150} = options

	setId: (@id) ->

	setArrowLeft: (boolean) -> @left = boolean
	setArrowRight: (boolean) -> @right = boolean

	getText: -> ''

	getPath: ->
		deltaX = @target.x - @source.x
		deltaY = @target.y - @source.y
		dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
		normX = deltaX / dist
		normY = deltaY / dist

		if @source.shape is 'rect'
			sourcePadding = if @left then @source.radius + 5 else @source.radius
		else
			sourcePadding = if @left then @source.radius + 5 else @source.radius

		if @target.shape is 'rect'
			targetPadding = if @right then @target.radius + 5 else @target.radius
		else
			targetPadding = if @right then @target.radius + 5 else @target.radius

		sourceX = @source.x + sourcePadding * normX
		sourceY = @source.y + sourcePadding * normY
		targetX = @target.x - targetPadding * normX
		targetY = @target.y - targetPadding * normY
		'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY
