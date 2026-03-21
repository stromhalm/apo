describe 'editorCanvas directive', ->
	activeTool = null
	element = null
	mockNet = null
	originalCancelAnimationFrame = null
	originalRequestAnimationFrame = null
	scope = null
	svgElement = null

	buildSimulation = ->
		simulation = {}
		simulation.nodes = jasmine.createSpy('nodes').and.returnValue(simulation)
		simulation.links = jasmine.createSpy('links').and.returnValue(simulation)
		simulation.linkDistance = jasmine.createSpy('linkDistance').and.returnValue(simulation)
		simulation.linkStrength = jasmine.createSpy('linkStrength').and.returnValue(simulation)
		simulation.friction = jasmine.createSpy('friction').and.returnValue(simulation)
		simulation.charge = jasmine.createSpy('charge').and.returnValue(simulation)
		simulation.gravity = jasmine.createSpy('gravity').and.returnValue(simulation)
		simulation.on = jasmine.createSpy('on').and.returnValue(simulation)
		simulation.start = jasmine.createSpy('start').and.returnValue(simulation)
		simulation.stop = jasmine.createSpy('stop').and.returnValue(simulation)
		simulation.size = jasmine.createSpy('size').and.returnValue(simulation)
		simulation.resume = jasmine.createSpy('resume').and.returnValue(simulation)
		simulation

	buildTool = ->
		name: 'Places'
		draggable: false
		clickOnCanvas: jasmine.createSpy('clickOnCanvas')
		dblClickOnCanvas: jasmine.createSpy('dblClickOnCanvas')
		mouseDownOnCanvas: jasmine.createSpy('mouseDownOnCanvas')
		mouseUpOnCanvas: jasmine.createSpy('mouseUpOnCanvas')
		clickOnNode: jasmine.createSpy('clickOnNode')
		dblClickOnNode: jasmine.createSpy('dblClickOnNode')
		mouseDownOnNode: jasmine.createSpy('mouseDownOnNode')
		mouseUpOnNode: jasmine.createSpy('mouseUpOnNode')
		clickOnEdge: jasmine.createSpy('clickOnEdge')
		dblClickOnEdge: jasmine.createSpy('dblClickOnEdge')
		mouseDownOnEdge: jasmine.createSpy('mouseDownOnEdge')
		mouseUpOnEdge: jasmine.createSpy('mouseUpOnEdge')

	beforeEach module 'app'

	beforeEach module ($provide) ->
		activeTool = buildTool()
		mockNet =
			name: 'Spec Net'
			nodes: []
			edges: []
			tools: [activeTool]
			getActiveTool: -> activeTool
			isConnectable: -> false

		$provide.value 'netStorageService',
			nets: [mockNet]
			getNetByName: -> mockNet
			deleteNet: jasmine.createSpy('deleteNet')
		$provide.value '$state',
			go: jasmine.createSpy('go')
		$provide.value '$stateParams',
			name: encodeURI(mockNet.name)
		$provide.value 'converterService', {}
		$provide.value 'formDialogService', {}

	beforeEach inject ($compile, $rootScope, $timeout) ->
		animationTimestamp = 0
		originalRequestAnimationFrame = window.requestAnimationFrame
		originalCancelAnimationFrame = window.cancelAnimationFrame
		window.requestAnimationFrame = (callback) ->
			animationTimestamp += 90
			callback(animationTimestamp)
			animationTimestamp
		window.cancelAnimationFrame = ->

		spyOn(d3.layout, 'force').and.callFake(buildSimulation)

		element = angular.element('<editor-canvas></editor-canvas>')
		angular.element(document.body).append(element)
		$compile(element)($rootScope.$new())
		$rootScope.$digest()

		scope = element.scope()
		svgElement = element[0].querySelector('svg')
		svgElement.getBoundingClientRect = ->
			left: 100
			top: 50
			width: 800
			height: 600

		$timeout.flush()

	afterEach ->
		window.requestAnimationFrame = originalRequestAnimationFrame
		window.cancelAnimationFrame = originalCancelAnimationFrame
		element.remove() if element

	it 'changes the scale when using the zoom controls', ->
		event =
			preventDefault: ->
			stopPropagation: ->

		expect(scope.viewport.scale).toBe 1

		scope.zoomIn(event)
		expect(scope.viewport.scale).toBeCloseTo 1.2, 5

		scope.zoomOut(event)
		expect(scope.viewport.scale).toBeCloseTo 1, 5

	it 'pans the viewport when dragging the empty canvas', ->
		scope.mouseDownOnCanvas({
			target: svgElement
			clientX: 110
			clientY: 70
		})
		scope.mouseMoveOnCanvas({
			clientX: 150
			clientY: 120
		})
		scope.mouseUpOnCanvas({})

		expect(scope.viewport.translateX).toBe 40
		expect(scope.viewport.translateY).toBe 50
		expect(activeTool.mouseDownOnCanvas).not.toHaveBeenCalled()

	it 'translates canvas clicks through the viewport transform', ->
		scope.viewport.scale = 2
		scope.viewport.translateX = 50
		scope.viewport.translateY = 30

		scope.clickOnCanvas({
			target: svgElement
			clientX: 170
			clientY: 130
		})

		clickArgs = activeTool.clickOnCanvas.calls.mostRecent().args
		clickPoint = clickArgs[1]
		expect(clickPoint.x).toBeCloseTo 10, 5
		expect(clickPoint.y).toBeCloseTo 25, 5

	it 'does not start panning while a node drag is active', ->
		node = new Place({id: 1, x: 20, y: 30})
		nodeEvent =
			preventDefault: ->
			stopPropagation: ->

		scope.mouseDownOnNode(node, nodeEvent)
		scope.mouseMoveOnCanvas({
			target: svgElement
			clientX: 180
			clientY: 140
		})

		expect(scope.viewport.translateX).toBe 0
		expect(scope.viewport.translateY).toBe 0
