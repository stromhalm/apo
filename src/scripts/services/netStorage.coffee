class NetStorage extends Factory
	constructor: ($localStorage) ->

		storage = $localStorage.$default
			nets: [ new TransitionSystem
				name: "Sample Net"
				nodes: []
				edges: []
			]

		getNetIdByName = (name) ->
			return id for net, id in storage.nets when net.name is name
			return false

		return {

			storageObjects: storage.nets

			getNets: ->
				allNets = []
				for net in storage.nets
					allNets.push(@getNetFromData(net))
				allNets

			addTransitionSystem: (name) ->
				if (@getNetByName(name))
					return false
				storage.nets.push(

					net = new TransitionSystem(
						name: name
						nodes: []
						edges: []
					)
				)

			addPetriNet: (name) ->
				if (@getNetByName(name))
					return false
				storage.nets.push(
					new PetriNet(
						name: name
						nodes: []
						edges: []
					)
				)

			deleteNet: (name) ->
				storage.nets.splice(getNetIdByName(name), 1)

			getNetByName: (name) ->
				return @getNetFromData(net) for net in storage.nets when net.name is name
				return false

			getNetFromData: (netData) ->
				switch netData.type
					when "lts" then return new TransitionSystem(netData)
					when "pn" then return new PetriNet(netData)
					else return new TransitionSystem(netData)

			getNodeFromData: (nodeData) ->
				switch nodeData.type
					when "transition" then return new Transition(nodeData)
					when "place" then return new Place(nodeData)
					when "state" then return new State(nodeData)
		}
