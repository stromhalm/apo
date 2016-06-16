class @PetriNet extends @Net
	constructor: (netObject) ->
		@type = "pn"
		super(netObject)
		@addTool(new Tool("Place", "radio_button_unchecked"))
		@addTool(new Tool("Transition", "check_box_outline_blank"))
		@addTool(new Tool("Token", "play_circle_outline"))

	addTransition: (point) ->
		transition = new Transition(point)
		@addNode(transition)

	addPlace: (point) ->
		place = new Place(point)
		@addNode(place)

	toolAddNew: (point) ->
		if @activeTool is "Transition"
			@addTransition(point)
		else
			@addPlace(point)
