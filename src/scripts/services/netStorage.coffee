class NetStorage extends Factory
	constructor: ($localStorage, TransitionSystemFactory) ->

		storage = $localStorage.$default
			nets: [ new TransitionSystemFactory
				name: "Sample Net"
				nodes: []
				edges: []
			]

		return {
			getNets: -> storage.nets

			addNet: (name) ->
				if (@getNetByName(name))
					return false
				storage.nets.push(
					new TransitionSystemFactory(
						name: name
						nodes: []
						edges: []
					)
				)

			deleteNet: (id) -> storage.nets.splice(id, 1)

			getNetByName: (name) ->
				return net for net in storage.nets when net.name is name
				return false
		}
