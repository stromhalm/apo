class NetStorage extends Service
	constructor: (converterService, $localStorage, $state, $stateParams) ->

		# Create a sample petri net
		getDefaultNet = ->
			defaultNet = new PetriNet({name: "Sample Net"})
			p1 = new Place({tokens: 5, label: "p1"})
			p2 = new Place({tokens: 3, label: "p2"})
			t1 = new Transition({label: "t1"})

			defaultNet.addNode(p1)
			defaultNet.addNode(p2)
			defaultNet.addNode(t1)
			
			defaultNet.addEdge(new PnEdge({source: t1, target: p1, right: 2}))
			defaultNet.addEdge(new PnEdge({source: p2, target: t1, right: 1}))

			console.log(defaultNet)

			defaultNet

		# Search for a net
		getNetIdByName = (name) ->
			return id for net, id in storage.nets when net.name is name
			return false

		# Create a sample petri net
		storage = $localStorage.$default
			nets: [getDefaultNet()]

		# Bind the storage to nets in $localStorage
		@storageObjects = storage.nets

		# Get an array with all nets
		@getNets = ->
			allNets = []
			for net in storage.nets
				allNets.push(converterService.getNetFromData(net))
			allNets

		# Add a new net to the storage
		@addNet = (net) ->
			if (net.name is "" or net.name is undefined or @getNetByName(net.name))
				return false
			storage.nets.push(net)

		# Rename a net in the storage
		@renameNet = (oldName, newName) ->
			if (newName is "" or newName is undefined or @getNetByName(newName))
				return false
			oldNet.name = newName for oldNet in storage.nets when oldNet.name is oldName
			return true

		# Delete a net and its references in the storage
		@deleteNet = (name) ->
			storage.nets.splice(getNetIdByName(name), 1)
			storage.nets.push(getDefaultNet()) if storage.nets.length is 0
			# Go to first net if current net has been deleted
			if name is decodeURI($stateParams.name)
				$state.go "editor", name: ""

		# Search for a net in the storage by name
		@getNetByName = (name) ->
			return converterService.getNetFromData(net) for net in storage.nets when net.name is name
			return false

		# Reset the storage
		@resetStorage = ->
			storage.nets.splice(0, 1) while storage.nets.length > 0
			storage.nets.push(getDefaultNet())
			$state.go "editor", name: ""
