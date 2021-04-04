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

			defaultNet

		# Define storage with default sample net
		storage = $localStorage.$default
			nets: [getDefaultNet()]

		# Direct 2-way-binded (outside) access to stored nets
		@nets = storage.nets

		# Restore all nets classes upon initialization
		for net, index in @nets
			@nets.splice(index, 1)
			@nets.push(converterService.getNetFromData(net))

		# Search for a net
		getNetIdByName = (name) ->
			return id for net, id in @nets when net.name is name
			return false

		# Add a new net to the storage
		@addNet = (net) ->
			if (net.name is "" or net.name is undefined or @getNetByName(net.name))
				return false
			@nets.push(net)

		# Rename a net in the storage
		@renameNet = (oldName, newName) ->
			if (newName is "" or newName is undefined or @getNetByName(newName))
				return false
			oldNet.name = newName for oldNet in @nets when oldNet.name is oldName
			return true

		# Delete a net and its references in the storage
		@deleteNet = (name) ->
			@nets.splice(getNetIdByName(name), 1)
			@nets.push(getDefaultNet()) if @nets.length is 0
			# Go to first net if current net has been deleted
			if name is decodeURI($stateParams.name)
				$state.go "editor", name: ""

		# Search for a net in the storage by name
		@getNetByName = (name) ->
			return net for net in @nets when net.name is name
			return false

		# Reset the storage
		@resetStorage = ->
			@nets.splice(0, 1) while @nets.length > 0
			@nets.push(getDefaultNet())
			$state.go "editor", name: ""
