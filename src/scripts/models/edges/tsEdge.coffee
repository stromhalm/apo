class @TsEdge extends @Edge
	constructor: (options)->
		{@labelLeft = "", @labelRight = ""} = options
		@type = "tsEdge"
		super(options)

	getText: ->
		if @left >= 1 and @right >= 1
			if @labelLeft is ""
				return "#{@labelRight} →"
			if @labelRight is ""
				return "← #{@labelLeft}"
			return "← #{@labelLeft} | #{@labelRight} →"
		else if @left >= 1
			return @labelLeft
		else if @right >= 1
			return @labelRight
