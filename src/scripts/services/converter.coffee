class Converter extends Service
	constructor: ->

		@getNetFromData = (netData) ->
			switch netData.type
				when "lts" then return new TransitionSystem(netData)
				when "pn" then return new PetriNet(netData)
				else return new TransitionSystem(netData)

		@getEdgeFromData = (edgeData) ->
			switch edgeData.type
				when "pnEdge" then return new PnEdge(edgeData)
				when "tsEdge" then return new TsEdge(edgeData)
				else return new Edge(edgeData)

		@getNodeFromData = (nodeData) ->
			switch nodeData.type
				when "transition" then return new Transition(nodeData)
				when "place" then return new Place(nodeData)
				when "state" then return new State(nodeData)
				when "initState" then return new InitState(nodeData)
				else return new Node(nodeData)

		@netToApt = (net) ->
			code = ""
			rows = []
			rows.push ".name \"#{net.name}\""

			# convert transition systems
			if net.type is "lts"
				rows.push ".type LTS"
				rows.push ""

				# add states
				rows.push ".states"
				initState = net.getInitState()
				for state in net.nodes when state.type is "state"
					if state is initState
						initial = "[initial]"
					else
						initial = ""
					state = @getNodeFromData(state)
					rows.push state.getText() + initial
				rows.push ""

				# add labels
				rows.push ".labels"
				labels = []
				for edge in net.edges
					if edge.type is "tsEdge"
						labels.push edge.labelLeft if edge.left >= 1 and labels.indexOf(edge.labelLeft) is -1
						labels.push edge.labelRight if edge.right >= 1 and labels.indexOf(edge.labelRight) is -1
				rows.push label for label in labels
				rows.push ""

				# add arcs
				rows.push ".arcs"
				for edge in net.edges
					if edge.type is "tsEdge"
						source = @getNodeFromData(edge.source)
						target = @getNodeFromData(edge.target)
						if edge.left >= 1
							rows.push "" + target.getText() + " " + edge.labelLeft + " " + source.getText()
						if edge.right >= 1
							rows.push "" + source.getText() + " " + edge.labelRight + " " + target.getText()

			# convert petri nets
			else if net.type is "pn"
				rows.push ".type PN"
				rows.push ""

				# add places
				rows.push ".places"
				for place in net.nodes when place.type is "place"
					place = @getNodeFromData(place)
					rows.push place.getText()
				rows.push ""

				# add transitions
				rows.push ".transitions"
				for transition in net.nodes when transition.type is "transition"
					transition = @getNodeFromData(transition)
					rows.push transition.getText()
				rows.push ""

				# add flows
				rows.push ".flows"
				for transition in net.nodes when transition.type is "transition"
					transition = @getNodeFromData(transition)
					row = transition.getText() + ": {"
					preset = net.getPreset(transition)
					for place, index in preset
						place = @getNodeFromData(place)
						row += net.getEdgeWeight(place, transition) + "*" + place.getText()
						row += ", " if index isnt preset.length - 1
					row += "} -> {"
					postset = net.getPostset(transition)
					for place, index in postset
						place = @getNodeFromData(place)
						row += net.getEdgeWeight(transition, place) + "*" + place.getText()
						row += ", " if index isnt postset.length - 1
					row += "}"
					rows.push row
				rows.push ""

				# add initial marking
				row = ".initial_marking {"
				placesWithTokens = []
				placesWithTokens.push place for place in net.nodes when place.type is "place" and place.token >= 1
				for place, index in placesWithTokens
					place = @getNodeFromData(place)
					row += place.token + "*" + place.getText()
					row += ", " if index isnt placesWithTokens.length - 1
				row += "}"
				rows.push row


			# return code as String
			code += row + "\r" for row in rows
			return code
