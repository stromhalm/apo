<script lang="ts">
  import { onMount, onDestroy, createEventDispatcher } from 'svelte';
  import * as d3 from 'd3';
  import type { Net, NetNode, NetEdge, Point, ToolType } from '$lib/types.js';
  import { getToolActions, getToolsForNetType } from '$lib/tools.js';
  import { connectNodes, isFirable } from '$lib/nets.js';
  import { getNodeText, getTokenLabel, getSelfEdgePath, getSelfEdgeText } from '$lib/nodes.js';
  import { getEdgePath, getEdgeText } from '$lib/edges.js';

  export let currentNet: Net;

  const dispatch = createEventDispatcher<{
    netUpdate: Net;
  }>();

  // Canvas state
  let svgElement: SVGElement;
  let width = 800;
  let height = 600;
  let isDestroyed = false;

  // D3 variables
  let force: any;
  let drag: any;
  let svg: any;
  let nodes: any;
  let edges: any;
  let dragLine: any;

  // Mouse interaction state
  let mouseDownNode: NetNode | null = null;
  let mouseUpNode: NetNode | null = null;
  let mouseDownEdge: NetEdge | null = null;
  let selectedNode: NetNode | null = null;

  // Physics parameters
  const charge = -500;
  const linkStrength = 0.1;
  const friction = 0.9;
  const gravity = 0.1;

  onMount(() => {
    initializeCanvas();
    updateNet();
  });

  onDestroy(() => {
    isDestroyed = true;
    if (force) {
      force.stop();
    }
  });

  // Watch for net changes
  $: if (currentNet && svg) {
    updateNet();
  }

  function initializeCanvas() {
    // Set up D3 SVG
    svg = d3.select(svgElement);
    
    // Create force layout
    force = d3.layout.force();
    drag = force.drag();

    // Create drag line for connecting nodes
    dragLine = svg.append('path')
      .attr('class', 'link dragline hidden')
      .style('marker-end', 'url(#endArrow)');

    // Create groups for edges and nodes
    edges = svg.append('g').selectAll('.edge');
    nodes = svg.append('g').selectAll('.node-group');

    // Set up window resize handler
    const handleResize = () => {
      if (isDestroyed) return;
      
      const rect = svgElement.getBoundingClientRect();
      width = rect.width;
      height = rect.height;
      
      svg.attr('width', width).attr('height', height);
      force.size([width, height]).resume();
    };

    // Set initial size
    handleResize();
    
    // Listen for resize events
    window.addEventListener('resize', handleResize);

    // Set up mouse event handlers
    svg.on('mousedown', handleCanvasMouseDown)
       .on('mousemove', handleCanvasMouseMove)
       .on('mouseup', handleCanvasMouseUp);

    // Set up force layout
    force.size([width, height])
         .linkDistance((d: NetEdge) => d.length)
         .linkStrength(linkStrength)
         .friction(friction)
         .charge(charge)
         .gravity(gravity)
         .on('tick', tick);
  }

  function updateNet() {
    if (!currentNet || !force || isDestroyed) return;

    // Update force layout with new data
    force.nodes(currentNet.nodes).links(currentNet.edges);

    // Fix broken node references in edges
    currentNet.edges.forEach(edge => {
      edge.source = currentNet.nodes.find(n => n.id === edge.source.id) || edge.source;
      edge.target = currentNet.nodes.find(n => n.id === edge.target.id) || edge.target;
    });

    restart();
  }

  function restart() {
    if (isDestroyed) return;

    // Update edges
    edges = edges.data(currentNet.edges, (d: NetEdge) => d.id);

    // Remove old edges
    edges.exit().remove();

    // Add new edges
    const newEdges = edges.enter().append('path')
      .attr('class', 'link edge')
      .attr('id', (d: NetEdge) => `edge-${d.id}`)
      .style('marker-start', (d: NetEdge) => d.left > 0 ? 'url(#startArrow)' : '')
      .style('marker-end', (d: NetEdge) => d.right > 0 ? 'url(#endArrow)' : '')
      .on('mousedown', handleEdgeMouseDown);

    // Update existing edges
    edges.style('marker-start', (d: NetEdge) => d.left > 0 ? 'url(#startArrow)' : '')
         .style('marker-end', (d: NetEdge) => d.right > 0 ? 'url(#endArrow)' : '');

    // Update nodes
    nodes = nodes.data(currentNet.nodes, (d: NetNode) => d.id);

    // Remove old nodes
    nodes.exit().remove();

    // Add new nodes
    const newNodes = nodes.enter().append('g')
      .attr('class', 'node-group')
      .call(drag);

    // Add node shapes
    newNodes.each(function(d: NetNode) {
      const group = d3.select(this);
      
      if (d.type === 'transition') {
        group.append('rect')
          .attr('class', `node ${d.type}`)
          .attr('width', d.radius * 2)
          .attr('height', d.radius * 2)
          .attr('x', -d.radius)
          .attr('y', -d.radius);
      } else {
        group.append('circle')
          .attr('class', `node ${d.type}`)
          .attr('r', d.radius);
      }
    });

    // Add node labels
    newNodes.append('text')
      .attr('class', 'node-label')
      .attr('text-anchor', 'middle')
      .attr('dy', '.35em')
      .text((d: NetNode) => getNodeText(d));

    // Add token labels for places
    newNodes.filter((d: NetNode) => d.type === 'place')
      .append('text')
      .attr('class', 'token-label')
      .attr('text-anchor', 'middle')
      .attr('dy', '1.5em')
      .text((d: NetNode) => getTokenLabel(d));

    // Add self-edges for states
    newNodes.filter((d: NetNode) => d.type === 'state')
      .append('path')
      .attr('class', 'link self-edge')
      .attr('d', (d: NetNode) => getSelfEdgePath(d))
      .style('marker-end', 'url(#endArrow)');

    // Update node event handlers
    nodes.on('mousedown', handleNodeMouseDown)
         .on('mouseup', handleNodeMouseUp)
         .on('dblclick', handleNodeDoubleClick);

    // Update node classes based on state
    nodes.select('.node')
         .classed('firable', (d: NetNode) => d.type === 'transition' && isFirable(currentNet, d))
         .classed('fixed', (d: NetNode) => !!d.fixed);

    // Update labels
    nodes.select('.node-label')
         .text((d: NetNode) => getNodeText(d));

    nodes.select('.token-label')
         .text((d: NetNode) => getTokenLabel(d));

    // Start simulation
    force.start();
  }

  function tick() {
    if (isDestroyed) return;

    // Update edge positions
    edges.attr('d', (d: NetEdge) => getEdgePath(d));

    // Update node positions
    nodes.attr('transform', (d: NetNode) => `translate(${d.x},${d.y})`);
  }

  function handleCanvasMouseDown(event: MouseEvent) {
    if (mouseDownNode || mouseDownEdge) return;

    const [x, y] = d3.mouse(svgElement);
    const point: Point = { x, y };
    
    const toolActions = getToolActions(currentNet.activeTool);
    if (toolActions.onMouseDownOnCanvas) {
      const updatedNet = toolActions.onMouseDownOnCanvas(currentNet, point);
      dispatch('netUpdate', updatedNet);
    }
  }

  function handleCanvasMouseMove(event: MouseEvent) {
    if (!mouseDownNode) return;

    const [x, y] = d3.mouse(svgElement);
    dragLine.attr('d', `M${mouseDownNode.x},${mouseDownNode.y}L${x},${y}`);
  }

  function handleCanvasMouseUp() {
    if (mouseDownNode) {
      dragLine.classed('hidden', true).style('marker-end', '');
    }
    resetMouseVars();
  }

  function handleNodeMouseDown(event: MouseEvent, d: NetNode) {
    event.stopPropagation();
    
    mouseDownNode = d;
    selectedNode = d;

    // Show drag line for arrow tool
    if (currentNet.activeTool === 'arrow') {
      dragLine.classed('hidden', false)
              .style('marker-end', 'url(#endArrow)')
              .attr('d', `M${d.x},${d.y}L${d.x},${d.y}`);
    }

    const toolActions = getToolActions(currentNet.activeTool);
    if (toolActions.onMouseDownOnNode) {
      const updatedNet = toolActions.onMouseDownOnNode(currentNet, d);
      dispatch('netUpdate', updatedNet);
    }
  }

  function handleNodeMouseUp(event: MouseEvent, d: NetNode) {
    event.stopPropagation();
    
    mouseUpNode = d;

    // Handle arrow connections
    if (currentNet.activeTool === 'arrow' && mouseDownNode && mouseUpNode && mouseDownNode !== mouseUpNode) {
      const updatedNet = connectNodes(currentNet, mouseDownNode, mouseUpNode);
      dispatch('netUpdate', updatedNet);
    }

    const toolActions = getToolActions(currentNet.activeTool);
    if (toolActions.onMouseUpOnNode) {
      const updatedNet = toolActions.onMouseUpOnNode(currentNet, mouseUpNode, mouseDownNode);
      dispatch('netUpdate', updatedNet);
    }

    dragLine.classed('hidden', true).style('marker-end', '');
    resetMouseVars();
  }

  function handleNodeDoubleClick(event: MouseEvent, d: NetNode) {
    event.stopPropagation();
    
    const toolActions = getToolActions(currentNet.activeTool);
    if (toolActions.onDoubleClickOnNode) {
      const updatedNet = toolActions.onDoubleClickOnNode(currentNet, d);
      dispatch('netUpdate', updatedNet);
    }
  }

  function handleEdgeMouseDown(event: MouseEvent, d: NetEdge) {
    event.stopPropagation();
    
    mouseDownEdge = d;
    selectedNode = null;

    const toolActions = getToolActions(currentNet.activeTool);
    if (toolActions.onMouseDownOnEdge) {
      const updatedNet = toolActions.onMouseDownOnEdge(currentNet, d);
      dispatch('netUpdate', updatedNet);
    }
  }

  function resetMouseVars() {
    mouseDownNode = null;
    mouseUpNode = null;
    mouseDownEdge = null;
  }
</script>

<div class="canvas-container tool-{currentNet.activeTool}">
  <svg
    bind:this={svgElement}
    class="editor-canvas"
    width="100%"
    height="100%"
  >
    <!-- Arrowhead markers -->
    <defs>
      <marker
        id="endArrow"
        viewBox="0 -5 10 10"
        refX="8"
        markerWidth="4"
        markerHeight="4"
        orient="auto"
        markerUnits="strokeWidth"
      >
        <path d="M0,-5L10,0L0,5" fill="currentColor" />
      </marker>
      <marker
        id="startArrow"
        viewBox="0 -5 10 10"
        refX="2"
        markerWidth="4"
        markerHeight="4"
        orient="auto"
        markerUnits="strokeWidth"
      >
        <path d="M10,-5L0,0L10,5" fill="currentColor" />
      </marker>
    </defs>
  </svg>
</div>

<style>
  .canvas-container {
    width: 100%;
    height: 100%;
    position: relative;
    background: white;
    cursor: default;
  }

  :global(.editor-canvas .link) {
    fill: none;
    stroke: #374151;
    stroke-width: 2px;
    cursor: default;
  }

  :global(.editor-canvas .link.dragline) {
    pointer-events: none;
    stroke-dasharray: 5,5;
  }

  :global(.editor-canvas .link.hidden) {
    stroke-width: 0;
  }

  :global(.editor-canvas .node) {
    fill: white;
    stroke: #374151;
    stroke-width: 2px;
    cursor: pointer;
  }

  :global(.editor-canvas .node.transition) {
    fill: #ddd6fe;
  }

  :global(.editor-canvas .node.place) {
    fill: #dbeafe;
  }

  :global(.editor-canvas .node.state) {
    fill: #dcfce7;
  }

  :global(.editor-canvas .node.firable) {
    stroke: #059669;
    stroke-width: 3px;
  }

  :global(.editor-canvas .node.fixed) {
    stroke: #dc2626;
  }

  :global(.editor-canvas text) {
    font-family: system-ui, sans-serif;
    font-size: 12px;
    fill: #374151;
    pointer-events: none;
    user-select: none;
  }

  :global(.editor-canvas .node-label) {
    font-weight: bold;
  }

  :global(.editor-canvas .token-label) {
    font-size: 10px;
    fill: #dc2626;
    font-weight: bold;
  }

  /* Tool-specific cursors */
  :global(.tool-arrow .editor-canvas .node),
  :global(.tool-delete .editor-canvas .node),
  :global(.tool-delete .editor-canvas .link) {
    cursor: crosshair;
  }

  :global(.tool-labels .editor-canvas .node),
  :global(.tool-labels .editor-canvas .link) {
    cursor: text;
  }

  :global(.tool-token .editor-canvas .node.place) {
    cursor: text;
  }

  :global(.tool-token .editor-canvas .node.transition) {
    cursor: not-allowed;
  }

  :global(.tool-token .editor-canvas .node.transition.firable) {
    cursor: pointer;
  }

  :global(.tool-move .editor-canvas .node) {
    cursor: move;
  }
</style>