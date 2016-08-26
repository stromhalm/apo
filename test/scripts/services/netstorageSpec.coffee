describe 'netStorageService', ->
	beforeEach module 'app'

	beforeEach ->
		jasmine.Expectation.addMatchers
			toEqualData: ->
				compare: (actual, expected) ->
					pass = angular.equals actual, expected
					{pass}

	it "should find a created transition system", inject ['netStorageService', (netStorageService) ->
		netName = "foo"
		netStorageService.addNet(new TransitionSystem({name: netName}))
		expect(netStorageService.getNetByName(netName).name).toEqualData netName
		expect(netStorageService.getNetByName(netName).type).toEqualData "lts"
	]

	it "should find a created petri net", inject ['netStorageService', (netStorageService) ->
		netName = "foo"
		netStorageService.addNet(new PetriNet({name: netName}))
		expect(netStorageService.getNetByName(netName).name).toEqualData netName
		expect(netStorageService.getNetByName(netName).type).toEqualData "pn"
	]

	it "should delete a transition system", inject ['netStorageService', (netStorageService) ->
		netName = "foo"
		netStorageService.addNet(new TransitionSystem({name: netName}))
		netStorageService.deleteNet(netName)
		expect(netStorageService.getNetByName(netName)).toEqualData false
	]

	it "should delete a petri net", inject ['netStorageService', (netStorageService) ->
		netName = "foo"
		netStorageService.addNet(new PetriNet({name: netName}))
		netStorageService.deleteNet(netName)
		expect(netStorageService.getNetByName(netName)).toEqualData false
	]
