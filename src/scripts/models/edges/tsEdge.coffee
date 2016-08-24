###
	Transition systems edges may have multiple labels to the left and to the right.
###

class @TsEdge extends @Edge
	constructor: (options)->
		{@labelsLeft = [], @labelsRight = []} = options
		@type = "tsEdge"
		super(options)

	getText: ->
		if @left >= 1 and @right >= 1
			if @labelsLeft.length is 0 and @labelsRight.length is 0
				return
			else if @labelsLeft.length is 0
				return "#{@labelsRight.join(", ")} →"
			else if @labelsRight.length is 0
				return "← #{@labelsLeft.join(", ")}"
			return "← #{@labelsLeft.join(", ")} | #{@labelsRight.join(", ")} →"
		else if @left >= 1
			return @labelsLeft.join(", ")
		else if @right >= 1
			return @labelsRight.join(", ")
