###
	This is an abstract class for directed edges that connect two nodes in an net.
	For bidirectional edges only one instace is used!
###

class @Edge
	constructor: (options) ->
		{@source, @target, @id, @left = 0, @right = 0, @length = 150} = options

	getText: -> ''

	getPath: ->
		deltaX = @target.x - @source.x
		deltaY = @target.y - @source.y
		dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
		normX = deltaX / dist
		normY = deltaY / dist
		sourcePadding = if @left >= 1 then @source.radius + 5 else @source.radius
		targetPadding = if @right >= 1 then @target.radius + 5 else @target.radius

		sourceX = @source.x + sourcePadding * normX
		sourceY = @source.y + sourcePadding * normY
		targetX = @target.x - targetPadding * normX
		targetY = @target.y - targetPadding * normY
		'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY
