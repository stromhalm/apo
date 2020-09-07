###
	Petri nets places may have a label and a number of tokens
###

class @Place extends @Node
	constructor: (point) ->
		super(point)
		{@tokens = 0} = point
		@type = "place"
		@connectableTypes = ["transition"]
		@labelYoffset = 30
		@radius = 18

	getText: ->
		return @label if @label
		return "p#{@id}"

	getTokenLabel: ->
		return "" if @tokens is 0
		return @tokens
