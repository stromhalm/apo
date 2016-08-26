class @TransitionSystem extends @Net
	constructor: (netObject) ->
		@type = "lts"
		super(netObject)

		# Setup for the transition systems tools in the right order
		@setTools([
			new MoveTool()
			new StateTool()
			new ArrowTool()
			new DeleteTool()
			new InitStateTool()
			new LabelTsTool()
		])

		# Setup for the transition systems analyzers in the right order
		@setAnalyzers([
			new ExamineLts()
			new Synthesizer()
		])

	# Add a state to the net
	addState: (point) ->
		state = new State(point)
		@addNode(state)

	# Get the nets init state
	getInitState: ->
		for node in @nodes when node.type is "initState"
			initNode = node
		return @getPostset(initNode)[0] if initNode
		return false

	# Set the nets init state. Internally the editor uses a hidden node.
	setInitState: (state) ->
		@deleteNode(node) for node in @nodes when node.type is "initState"
		initState = new InitState()
		@addNode(initState)
		arrow = new TsInitEdge({source: initState, target: state, right: 1})
		@addEdge(arrow)
