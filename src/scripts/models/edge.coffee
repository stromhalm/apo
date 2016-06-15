class @Edge
	constructor: (options) ->
		{@source, @target, @left = false, @right = false} = options

	setArrowLeft: (boolean) -> @left = boolean
	setArrowRight: (boolean) -> @right = boolean

	getPath: ->
		deltaX = @target.x - (@source.x)
		deltaY = @target.y - (@source.y)
		dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
		normX = deltaX / dist
		normY = deltaY / dist
		sourcePadding = if @left then 17 else 12
		targetPadding = if @right then 17 else 12
		sourceX = @source.x + sourcePadding * normX
		sourceY = @source.y + sourcePadding * normY
		targetX = @target.x - (targetPadding * normX)
		targetY = @target.y - (targetPadding * normY)
		'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY
