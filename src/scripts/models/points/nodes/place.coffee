###
	Petri nets places may have a label, a number of tokens and a token capacity
###

class @Place extends @Node
	constructor: (point) ->
		super(point)
		{@tokens = 0, @tokensCap = 255} = point
		@type = "place"
		@connectableTypes = ["transition"]
		@labelYoffset = 50
		@radius = 18

	getText: ->
		return @label if @label
		return "p#{@id}"

	getTokenLabel: ->
		return "" if @tokens is 0 and @tokensCap is 255
		return @tokens if @tokensCap is 255
		return "#{@tokens}/#{@tokensCap}"
