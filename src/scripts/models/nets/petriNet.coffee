class @PetriNet extends @Net
	constructor: (netObject) ->
		@type = "pn"
		super(netObject)

	addTransition: (point) ->
		transition = new Transition(point)
		@addNode(transition)

	addPlace: (point) ->
		place = new Place(point)
		@addNode(place)
