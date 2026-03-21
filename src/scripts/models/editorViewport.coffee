class @EditorViewport
	@clampScale: (scale) ->
		numericScale = parseFloat(scale)
		numericScale = 1 if not isFinite(numericScale)
		Math.max(0.25, Math.min(4, numericScale))

	constructor: (options = {}) ->
		@scale = @constructor.clampScale(options.scale ? 1)
		@translateX = options.translateX ? 0
		@translateY = options.translateY ? 0

	getTransform: ->
		"translate(#{@translateX},#{@translateY}) scale(#{@scale})"

	getCanvasPoint: (clientX, clientY, rect) ->
		left = rect?.left ? 0
		top = rect?.top ? 0
		{
			x: (clientX - left - @translateX) / @scale
			y: (clientY - top - @translateY) / @scale
		}

	panBy: (deltaX, deltaY) ->
		@translateX += deltaX
		@translateY += deltaY
		this

	zoomAroundClientPoint: (nextScale, clientX, clientY, rect) ->
		clampedScale = @constructor.clampScale(nextScale)
		return this if clampedScale is @scale

		anchorPoint = @getCanvasPoint(clientX, clientY, rect)
		left = rect?.left ? 0
		top = rect?.top ? 0
		relativeX = clientX - left
		relativeY = clientY - top

		@translateX = relativeX - anchorPoint.x * clampedScale
		@translateY = relativeY - anchorPoint.y * clampedScale
		@scale = clampedScale
		this
