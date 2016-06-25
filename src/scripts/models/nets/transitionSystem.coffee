class @TransitionSystem extends @Net
	constructor: (netObject) ->
		@type = "lts"
		super(netObject)
		@setTools([
			new StateTool()
			new ArrowTool()
			new DeleteTool()
			new InitStateTool()
			new LabelTsTool()
		])

	addState: (point) ->
		state = new State(point)
		@addNode(state)

	setInitState: (state) ->
		@deleteNode(node) for node in @nodes when node.type is "initState"
		initState = new InitState(new Point(state.x, state.y))
		@addNode(initState)
		arrow = new TsInitEdge({source: initState, target: state, right: true})
		@addEdge(arrow)
