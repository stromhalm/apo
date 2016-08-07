class @CoverabilityAnalyzer extends @Analyzer
	constructor: () ->
		super()
		@icon = "call_merge"
		@name = "Coverability Graph"
		@description =  "This module creates the coverability graph as a new transition system from an existing petri net."

	inputOptions: (currentNet, NetStorage) ->
		[
			{
				name: "Name of the new transition system"
				type: "text"
				value: "CG of #{currentNet.name}"
				validation: (name) ->
					return "The name can't contain \"" if name and name.replace("\"", "") isnt name
					return "A net with this name already exists" if name and NetStorage.getNetByName(name)
					return true
			}
		]

	analyze: (inputOptions, apt, net, converterService, NetStorage) ->
		aptNet = converterService.getAptFromNet(net)
		apt.getCoverabilityGraph(aptNet)
		.then (response) ->
			aptCov = response.data.coverabilityGraph
			covGraph = converterService.getNetFromApt(aptCov)
			covGraph.name = inputOptions[0].value
			NetStorage.addNet(covGraph)
