class PetriNet extends @Net
	constructor: (netObject) ->
		@type = "pn"
		super(netObject)

class PetriNetFactory extends Factory
	constructor: ->
		return PetriNet
