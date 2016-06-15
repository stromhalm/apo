class NetStorage extends Factory
	constructor: ($localStorage) ->

		storage = $localStorage.$default
			nets: [ new TransitionSystem
				name: "Sample Net"
				nodes: []
				edges: []
			]

		getNetFromStorageObject = (storageObject) ->
			switch storageObject.type
				when "lts" then return new TransitionSystem(storageObject)
				when "pn" then return new PetriNet(storageObject)
				else return new TransitionSystem(storageObject)

		getNetIdByName = (name) ->
			return id for net, id in storage.nets when net.name is name
			return false

		return {

			storageObjects: storage.nets

			getNets: ->
				allNets = []
				for net in storage.nets
					allNets.push(getNetFromStorageObject(net))
				allNets

			addTransitionSystem: (name) ->
				if (@getNetByName(name))
					return false
				storage.nets.push(
					new TransitionSystem(
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
				return getNetFromStorageObject(net) for net in storage.nets when net.name is name
				return false
		}
