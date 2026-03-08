###
	This is an abstract class for directed edges that connect two nodes in an net.
	For bidirectional edges only one instace is used!
###

class @Edge
	constructor: (options) ->
		{@source, @target, @id, @left = 0, @right = 0, @length = 150, @renderVersion = 0} = options

	getText: -> ''

	getPaddedPoints: ->
		return false if not isFinite(@source?.x) or not isFinite(@source?.y) or not isFinite(@target?.x) or not isFinite(@target?.y)

		deltaX = @target.x - @source.x
		deltaY = @target.y - @source.y
		dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
		normX = if dist == 0 then 0 else deltaX / dist
		normY = if dist == 0 then 0 else deltaY / dist

		arrowWidth = 5
		sourcePadding = if @left >= 1 then @source.radius + arrowWidth else @source.radius
		targetPadding = if @right >= 1 then @target.radius + arrowWidth else @target.radius

		{
			sourceX: @source.x + sourcePadding * normX
			sourceY: @source.y + sourcePadding * normY
			targetX: @target.x - targetPadding * normX
			targetY: @target.y - targetPadding * normY
			deltaX
			deltaY
		}

	getPath: ->
		points = @getPaddedPoints()
		return '' if not points
		'M' + points.sourceX + ',' + points.sourceY + 'L' + points.targetX + ',' + points.targetY

	isLabelReversed: ->
		points = @getPaddedPoints()
		return false if not points
		Math.atan2(points.deltaY, points.deltaX) > Math.PI / 2 or Math.atan2(points.deltaY, points.deltaX) < -Math.PI / 2

	getLabelText: ->
		@getText()

	getLabelPath: ->
		points = @getPaddedPoints()
		return '' if not points

		labelOffset = 8
		dist = Math.sqrt(points.deltaX * points.deltaX + points.deltaY * points.deltaY)
		return @getPath() if dist == 0

		normalAX = -points.deltaY / dist
		normalAY = points.deltaX / dist
		normalBX = points.deltaY / dist
		normalBY = -points.deltaX / dist

		if normalAY < normalBY or (normalAY is normalBY and normalAX < normalBX)
			normalX = normalAX
			normalY = normalAY
		else
			normalX = normalBX
			normalY = normalBY

		sourceX = points.sourceX + normalX * labelOffset
		sourceY = points.sourceY + normalY * labelOffset
		targetX = points.targetX + normalX * labelOffset
		targetY = points.targetY + normalY * labelOffset
		if @isLabelReversed()
			'M' + targetX + ',' + targetY + 'L' + sourceX + ',' + sourceY
		else
			'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY
