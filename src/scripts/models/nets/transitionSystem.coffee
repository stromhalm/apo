class @TransitionSystem extends @Net
	constructor: (netObject) ->
		@type = "lts"
		super(netObject)
		@setTools([
			new StateTool()
			new ArrowTool()
			new DeleteTool()
		])

	addState: (point) ->
		state = new State(point)
		@addNode(state)
