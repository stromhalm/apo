###
	This is the class for petri nets.
###

class @PetriNet extends @Net
	constructor: (netObject) ->
		super(netObject)
		@type = "pn"

		# Setup for the petri nets tools in the correct order
		@setTools([
			new MoveTool()
			new PlaceTool()
			new TransitionTool()
			new ArrowTool()
			new TokenTool()
			new DeleteTool()
			new LabelPnTool()
		])

		# Setup for the petri nets analyzers in the correct order
		@setAnalyzers([
			new ExaminePn()
			new CoverabilityAnalyzer()
		])

	# Add a new transition node
	addTransition: (point) ->
		transition = new Transition(point)
		@addNode(transition)

	# Add a new place node
	addPlace: (point) ->
		place = new Place(point)
		@addNode(place)

	# Checks if a transition is firable
	isFirable: (transition) ->
		return false if transition.type isnt "transition"
		preset = @getPreset(transition)
		return false for place in preset when parseInt(place.tokens) < @getEdgeWeight(place, transition)
		return true

	# Gets the weight of an edge between two nodes
	getEdgeWeight: (source, target) ->
		for edge in @edges
			if edge.source.id is source.id and edge.target.id is target.id
				return parseInt(edge.right)
			else if edge.source.id is target.id and edge.target.id is source.id
				return parseInt(edge.left)
		return 0

	# Fires a transition
	fireTransition: (transition) ->
		return false if not @isFirable(transition)
		preset = @getPreset(transition)
		postset = @getPostset(transition)
		for place in preset
			place.tokens = parseInt(place.tokens) - parseInt(@getEdgeWeight(place, transition))
		for place in postset
			place.tokens = parseInt(place.tokens) + parseInt(@getEdgeWeight(transition, place))
		return true
