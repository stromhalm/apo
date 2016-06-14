describe 'NetStorage', ->
	beforeEach module 'app'

	beforeEach ->
		jasmine.Expectation.addMatchers
			toEqualData: ->
				compare: (actual, expected) ->
					pass = angular.equals actual, expected

					{pass}

	it "should store and find a transition system", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addTransitionSystem(netName)
		expect(NetStorage.getNetByName(netName).name).toEqualData netName
		expect(NetStorage.getNetByName(netName).type).toEqualData "lts"
	]

	it "should store and find a petri net", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addPetriNet(netName)
		expect(NetStorage.getNetByName(netName).name).toEqualData netName
		expect(NetStorage.getNetByName(netName).type).toEqualData "pn"
	]
