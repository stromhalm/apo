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

	getInitState: ->
		for node in @nodes when node.type is "initState"
			initNode = node
		return @getPostset(initNode)[0] if initNode
		return false

	setInitState: (state) ->
		@deleteNode(node) for node in @nodes when node.type is "initState"
		initState = new InitState()
		@addNode(initState)
		arrow = new TsInitEdge({source: initState, target: state, right: 1})
		@addEdge(arrow)
