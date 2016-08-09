class @Synthesizer extends @Analyzer
	constructor: () ->
		super()
		@icon = "call_merge"
		@name = "Synthesizer"
		@description =  "Synthesize a petri net from a transition system"

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
			}
			{
				name: "[k]-bounded"
				type: "number"
				width: "flex"
				value: 1
				min: 1
				showIf: (inputOptions) ->
					return true for chosenOption in inputOptions[3].value when chosenOption.id is "[k]-bounded"
					return false
			}
			{
				name: "[k]-marking"
				type: "number"
				width: "flex"
				value: 1
				min: 1
				showIf: (inputOptions) ->
					return true for chosenOption in inputOptions[3].value when chosenOption.id is "[k]-marking"
					return false
			}
			{
				name: "Choose options"
				placeholder: "none"
				type: "textArray"
				value: []
				chooseFrom: [
					{id: "[k]-bounded", nicename: "[k]-bounded", description: "In every reachable marking, every place contains at most [k] tokens."}
					{id: "safe", nicename: "safe", description: "Equivalent to 1-bounded."}
					{id: "[k]-marking", nicename: "[k]-marking", description: "The initial marking of each place is a multiple of k."}
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

	analyze: (inputOptions, outputElements, currentNet, apt, converterService, NetStorage, formDialogService) ->
		aptNet = converterService.getAptFromNet(currentNet)
		options = []

		for option in inputOptions[3].value
			aptOption = option.id
			.replace("[k]-bounded", "#{inputOptions[1].value}-bounded")
			.replace("[k]-marking", "#{inputOptions[2].value}-marking")
			options.push(aptOption)
		apt.getSynthesizedNet(aptNet, options)
		.then (response) ->
			aptPn = response.data.pn
			if response.data.success
				pn = converterService.getNetFromApt(aptPn)
				pn.name = inputOptions[0].value
				NetStorage.addNet(pn)
				formDialogService.close()
			else
				outputElements.splice(0) while outputElements.length > 0 # clear outputElements
				outputElements.push(
					{
						name: "Success"
						value: "No"
						type: "text"
						touched: true
						validation: -> "" #false
					}
				)
				outputElements.push(
					{
						name: "Failed state separation problems"
						value: response.data.failedStateSeparationProblems
						type: "text"
						touched: true
						validation: -> "" #false
					}
				)
				outputElements.push(
					{
						name: "Failed event state separation problems"
						value: response.data.failedEventStateSeparationProblems
						type: "text"
						touched: true
						validation: -> false
					}
				)
				formDialogService.scrollToBottom()

		return false # do not close imediatly
