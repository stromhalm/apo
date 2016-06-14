class TransitionSystem extends @Net
	constructor: (netObject) ->
		@type = "lts"
		super(netObject)

class TransitionSystemFactory extends Factory
	constructor: ->
		return TransitionSystem
