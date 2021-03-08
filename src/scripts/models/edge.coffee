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
		normX = if dist == 0 then 0 else deltaX / dist
		normY = if dist == 0 then 0 else deltaY / dist

		arrowWidth = 5
		sourcePadding = if @left >= 1 then @source.radius + arrowWidth else @source.radius
		targetPadding = if @right >= 1 then @target.radius + arrowWidth else @target.radius

		sourceX = @source.x + sourcePadding * normX
		sourceY = @source.y + sourcePadding * normY
		targetX = @target.x - targetPadding * normX
		targetY = @target.y - targetPadding * normY
		'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY
