class NetStorage extends Factory
	constructor: ($localStorage) ->

		getDefaultNet = ->
			new TransitionSystem({name: "Sample Net"})

		getNetIdByName = (name) ->
			return id for net, id in storage.nets when net.name is name
			return false

		storage = $localStorage.$default
			nets: [getDefaultNet()]

		return {

			storageObjects: storage.nets

			getNets: ->
				allNets = []
				for net in storage.nets
					allNets.push(@getNetFromData(net))
				allNets

			addNet: (net) ->
				if (@getNetByName(net.name))
					return false
				storage.nets.push(net)

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
