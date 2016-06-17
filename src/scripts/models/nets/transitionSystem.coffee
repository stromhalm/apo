class @TransitionSystem extends @Net
	constructor: (netObject) ->
		@type = "lts"
		super(netObject)
		@setTools([
			new StateTool()
		])

	addState: (point) ->
		state = new State(point)
		@addNode(state)
