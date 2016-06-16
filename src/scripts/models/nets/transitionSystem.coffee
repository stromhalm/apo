class @TransitionSystem extends @Net
	constructor: (netObject) ->
		@type = "lts"
		super(netObject)
		@addTool(new Tool("State", "radio_button_unchecked"))

	addState: (point) ->
		state = new State(point)
		@addNode(state)

	toolAddNew: (point) -> @addState(point)
