class @CoverabilityAnalyzer extends @Analyzer
	constructor: () ->
		super()
		@icon = "call_merge"
		@name = "Coverability Graph"
		@infoText = "This module creates the coverability graph as a new transition system from an existing petri net."
		@options =
			[
				{
					name: "Name of the new net"
					type: "text"
				}
			]

	run: (apt, NetStorage, converterService, currentNet) ->
		aptNet = converterService.getAptFromNet(currentNet)
		apt.getCoverabilityGraph(aptNet).then((response) ->
			aptCov = response.data.coverabilityGraph
			console.log aptCov
			covGraph = converterService.getNetFromApt(aptCov)
			NetStorage.addNet(covGraph)
		)
