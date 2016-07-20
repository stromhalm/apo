class @CoverabilityAnalyzer extends @Analyzer
	constructor: () ->
		super()
		@icon = "call_merge"
		@name = "Coverability Graph"

	run: (apt, NetStorage, converterService, currentNet) ->
		aptNet = converterService.getAptFromNet(currentNet)
		apt.getCoverabilityGraph(aptNet).then((response) ->
			aptCov = response.data.coverabilityGraph
			covGraph = converterService.getNetFromApt(aptCov)
			NetStorage.addNet(covGraph)
		)
