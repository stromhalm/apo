class @CoverabilityAnalyzer extends @Analyzer
	constructor: () ->
		super()
		@icon = "call_merge"
		@name = "Coverability Graph"

	run: (apt, NetStorage, converterService, currentNet) ->
		aptNet = converterService.getAptFromNet(currentNet)
		aptCov = apt.getCoverabilityGraph(aptNet)
		covGraph = converterService.getNetFromApt(aptCov)
		NetStorage.addNet(covGraph)
