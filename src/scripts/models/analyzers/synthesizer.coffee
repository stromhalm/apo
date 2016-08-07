class @Synthesizer extends @Analyzer
	constructor: () ->
		super()
		@icon = "call_merge"
		@name = "Synthesizer"
		@description =  "This module synthesizes a petri net from an existing transition system."

	inputOptions: (currentNet, NetStorage) ->
		[
			{
				name: "Name of the new petri net"
				type: "text"
				value: "Synthesis of #{currentNet.name}"
				validation: (name) ->
					return "The name can't contain \"" if name and name.replace("\"", "") isnt name
					return "A net with this name already exists" if name and NetStorage.getNetByName(name)
					return true
			},
			{
				name: "none"
				type: "chooseArray"
				value: []
				chooseFrom: [
					{id: "[k]-bounded", nicename: "[k]-bounded", description: "In every reachable marking, every place contains at most [k] tokens."}
					{id: "safe", nicename: "safe", description: "Equivalent to 1-bounded."}
					{id: "[k]-marking", nicename: "[k]-marking", description: "Equivalent to 1-bounded."}
					{id: "pure", nicename: "pure", description: "Every transition either consumes or produces tokens on a place, but not both (=no side-conditions)."}
					{id: "plain", nicename: "plain", description: "Every flow has a weight of at most one."}
					{id: "tnet", nicename: "tnet", description: "Every place's preset and postset contains at most one entry."}
					{id: "generalized-marked-graph", nicename: "generalized marked graph", description: "Every place's preset and postset contains exactly one entry."}
					{id: "marked-graph", nicename: "marked graph", description: "generalized marked graph + plain."}
					{id: "generalized-output-nonbranching", nicename: "generalized output nonbranching", description: "Every place's postset contains at most one entry."}
					{id: "output-nonbranching", nicename: "output nonbranching", description: "generalized output nonbranching + plain."}
					{id: "conflict-free", nicename: "conflict free", description: "The Petri net is plain and every place either has at most one entry in its postset or its preset is contained in its postset."}
					{id: "homogeneous", nicename: "homogeneous", description: "All outgoing flows from a place have the same weight."}
					{id: "minimize", nicename: "minimize", description: "The Petri net has as few places as possible."}
				]
			}
		]

	analyze: (inputOptions, apt, net, converterService, NetStorage) ->
		aptNet = converterService.getAptFromNet(net)
		options = []
		options.push(option.id) for option in inputOptions[1].value
		apt.getSynthesizedNet(aptNet, options)
		.then (response) ->
			aptPn = response.data.pn
			pn = converterService.getNetFromApt(aptPn)
			pn.name = inputOptions[0].value
			NetStorage.addNet(pn)
