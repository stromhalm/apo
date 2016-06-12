describe 'NetStorage', ->
	beforeEach module 'app'

	beforeEach ->
		jasmine.Expectation.addMatchers
			toEqualData: ->
				compare: (actual, expected) ->
					pass = angular.equals actual, expected

					{pass}

	it "should create and find a net", inject ['NetStorage', (NetStorage) ->
		netName = "foo"
		NetStorage.addNet(netName)
		expect(NetStorage.getNetByName(netName).name).toEqualData netName
	]
