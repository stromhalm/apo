###
	Petri nets transitions may have a label
###

class @Transition extends @Node
	constructor: (point) ->
		super(point)
		@type = "transition"
		@connectableTypes = ["place"]
		@shape = "rect"
		@width = 36
		@height = 36

	getText: ->
		return @label if @label
		return "t#{@id}"
