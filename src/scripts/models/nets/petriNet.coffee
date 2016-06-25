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
			new LabelPnTool()
		])

	addTransition: (point) ->
		transition = new Transition(point)
		@addNode(transition)

	addPlace: (point) ->
		place = new Place(point)
		@addNode(place)

	isFirable: (transition) ->
		return false if transition.type isnt "transition"
		preset = @getPreset(transition)
		return false for place in preset when place.token < 1
		return true


	fireTransition: (transition) ->
		return false if not @isFirable(transition)
		preset = @getPreset(transition)
		postset = @getPostset(transition)
		place.token-- for place in preset
		place.token++ for place in postset
		return true
