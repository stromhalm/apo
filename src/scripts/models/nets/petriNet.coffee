class @PetriNet extends @Net
	constructor: (netObject) ->
		@type = "pn"
		super(netObject)
		@setTools([
			new PlaceTool()
			new TransitionTool()
			new ArrowTool()
			new TokenTool()
			new DeleteTool()
		])

	addTransition: (point) ->
		transition = new Transition(point)
		@addNode(transition)

	addPlace: (point) ->
		place = new Place(point)
		@addNode(place)
