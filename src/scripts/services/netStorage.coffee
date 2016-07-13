class NetStorage extends Factory
	constructor: (converterService, $localStorage, $state) ->

		getDefaultNet = ->
			new PetriNet({name: "Sample Net"})

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
					allNets.push(converterService.getNetFromData(net))
				allNets

			addNet: (net) ->
				if (net.name is "" or net.name is undefined or @getNetByName(net.name))
					return false
				storage.nets.push(net)

			renameNet: (oldName, newName) ->
				if (newName is "" or newName is undefined or @getNetByName(newName))
					return false
				oldNet.name = newName for oldNet in storage.nets when oldNet.name is oldName
				return true

			deleteNet: (name) ->
				storage.nets.splice(getNetIdByName(name), 1)
				storage.nets.push(getDefaultNet()) if storage.nets.length is 0

			getNetByName: (name) ->
				return converterService.getNetFromData(net) for net in storage.nets when net.name is name
				return false

			resetStorage: ->
				storage.nets.splice(0, 1) while storage.nets.length > 0
				storage.nets.push(getDefaultNet())
				$state.go "editor", name: storage.nets[0].name

		}
