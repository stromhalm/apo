describe 'EditorViewport', ->
	it 'clamps zoom to the supported range', ->
		expect(EditorViewport.clampScale(0.1)).toBe 0.25
		expect(EditorViewport.clampScale(2)).toBe 2
		expect(EditorViewport.clampScale(10)).toBe 4

	it 'translates client coordinates into canvas coordinates', ->
		viewport = new EditorViewport({
			scale: 2
			translateX: 40
			translateY: 30
		})

		point = viewport.getCanvasPoint(180, 130, {left: 100, top: 50})
		expect(point.x).toBe 20
		expect(point.y).toBe 25

	it 'keeps the anchored canvas point stable while zooming', ->
		viewport = new EditorViewport({
			scale: 1
			translateX: 20
			translateY: 10
		})
		rect = {left: 100, top: 50}
		anchorPointBeforeZoom = viewport.getCanvasPoint(220, 140, rect)

		viewport.zoomAroundClientPoint(2, 220, 140, rect)
		anchorPointAfterZoom = viewport.getCanvasPoint(220, 140, rect)

		expect(anchorPointAfterZoom.x).toBeCloseTo anchorPointBeforeZoom.x, 5
		expect(anchorPointAfterZoom.y).toBeCloseTo anchorPointBeforeZoom.y, 5
