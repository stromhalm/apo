describe 'NetStorage', ->
	beforeEach module 'app'

	beforeEach ->
		jasmine.Expectation.addMatchers
			toEqualData: ->
				compare: (actual, expected) ->
					pass = angular.equals actual, expected

					{pass}

	it "should find a created transition system", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addTransitionSystem(netName)
		expect(NetStorage.getNetByName(netName).name).toEqualData netName
		expect(NetStorage.getNetByName(netName).type).toEqualData "lts"
	]

	it "should find a created petri net", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addPetriNet(netName)
		expect(NetStorage.getNetByName(netName).name).toEqualData netName
		expect(NetStorage.getNetByName(netName).type).toEqualData "pn"
	]

	it "should delete a transition system", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addTransitionSystem(netName)
		NetStorage.deleteNet(netName)
		expect(NetStorage.getNetByName(netName)).toEqualData false
	]

	it "should delete a petri net", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addPetriNet(netName)
		NetStorage.deleteNet(netName)
		expect(NetStorage.getNetByName(netName)).toEqualData false
	]
