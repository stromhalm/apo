import type { Net, NetNode, NetEdge, Place, Transition, State, InitState, Point, NetType, ToolType } from './types.js';
import { createPlace, createTransition, createState, createInitState, isConnectable, getNodeText } from './nodes.js';
import { createPnEdge, createTsEdge, createTsInitEdge, getEdgeWeight, findEdge } from './edges.js';

// Net creation functions
export function createPetriNet(name: string): Net {
  return {
    id: crypto.randomUUID(),
    name,
    type: 'pn',
    nodes: [],
    edges: [],
    activeTool: 'move'
  };
}

export function createTransitionSystem(name: string): Net {
  return {
    id: crypto.randomUUID(),
    name,
    type: 'lts',
    nodes: [],
    edges: [],
    activeTool: 'move'
  };
}

// Sample net creation
export function createSamplePetriNet(): Net {
  const net = createPetriNet("Sample Net");
  
  const p1 = createPlace({ x: 100, y: 100, tokens: 5, label: "p1" });
  const p2 = createPlace({ x: 300, y: 100, tokens: 3, label: "p2" });
  const t1 = createTransition({ x: 200, y: 200, label: "t1" });
  
  net.nodes = [p1, p2, t1];
  assignNodeIds(net);
  
  const edge1 = createPnEdge({ source: t1, target: p1, right: 2 });
  const edge2 = createPnEdge({ source: p2, target: t1, right: 1 });
  
  net.edges = [edge1, edge2];
  assignEdgeIds(net);
  
  return net;
}

// Node management
export function addNode(net: Net, node: NetNode): Net {
  const newNet = { ...net };
  newNet.nodes = [...net.nodes, { ...node, id: getMaxNodeId(net) + 1 }];
  return newNet;
}

export function deleteNode(net: Net, nodeToDelete: NetNode): Net {
  const newNet = { ...net };
  
  // Delete connected edges
  newNet.edges = net.edges.filter(edge => 
    edge.source.id !== nodeToDelete.id && edge.target.id !== nodeToDelete.id
  );
  
  // Delete the node
  newNet.nodes = net.nodes.filter(node => node.id !== nodeToDelete.id);
  
  return newNet;
}

export function updateNode(net: Net, updatedNode: NetNode): Net {
  const newNet = { ...net };
  newNet.nodes = net.nodes.map(node => 
    node.id === updatedNode.id ? updatedNode : node
  );
  
  // Update edge references
  newNet.edges = net.edges.map(edge => ({
    ...edge,
    source: edge.source.id === updatedNode.id ? updatedNode : edge.source,
    target: edge.target.id === updatedNode.id ? updatedNode : edge.target
  }));
  
  return newNet;
}

// Edge management
export function addEdge(net: Net, edge: NetEdge): Net {
  const newNet = { ...net };
  newNet.edges = [...net.edges, { ...edge, id: getMaxEdgeId(net) + 1 }];
  return newNet;
}

export function deleteEdge(net: Net, edgeToDelete: NetEdge): Net {
  const newNet = { ...net };
  newNet.edges = net.edges.filter(edge => edge.id !== edgeToDelete.id);
  return newNet;
}

export function updateEdge(net: Net, updatedEdge: NetEdge): Net {
  const newNet = { ...net };
  newNet.edges = net.edges.map(edge => 
    edge.id === updatedEdge.id ? updatedEdge : edge
  );
  return newNet;
}

// Connection handling
export function connectNodes(net: Net, source: NetNode, target: NetNode): Net {
  if (!isConnectable(source, target) || source.id === target.id) {
    return net;
  }
  
  // Check for existing edge in both directions
  const forwardEdge = findEdge(net.edges, source, target, 'forward');
  const backwardEdge = findEdge(net.edges, source, target, 'backward');
  
  let newNet = { ...net };
  
  if (forwardEdge) {
    // Update existing forward edge
    newNet.edges = net.edges.map(edge => 
      edge.id === forwardEdge.id ? { ...edge, right: 1 } : edge
    );
  } else if (backwardEdge) {
    // Update existing backward edge
    newNet.edges = net.edges.map(edge => 
      edge.id === backwardEdge.id ? { ...edge, left: 1 } : edge
    );
  } else {
    // Create new edge
    const newEdge = net.type === 'pn' 
      ? createPnEdge({ source, target, right: 1 })
      : createTsEdge({ source, target, right: 1, labelsRight: [''] });
    
    newNet = addEdge(newNet, newEdge);
  }
  
  return newNet;
}

// Net analysis
export function getPreset(net: Net, node: NetNode): NetNode[] {
  const preset: NetNode[] = [];
  for (const edge of net.edges) {
    if (edge.target.id === node.id && edge.right >= 1) {
      preset.push(edge.source);
    } else if (edge.source.id === node.id && edge.left >= 1) {
      preset.push(edge.target);
    }
  }
  return preset;
}

export function getPostset(net: Net, node: NetNode): NetNode[] {
  const postset: NetNode[] = [];
  for (const edge of net.edges) {
    if (edge.target.id === node.id && edge.left >= 1) {
      postset.push(edge.source);
    } else if (edge.source.id === node.id && edge.right >= 1) {
      postset.push(edge.target);
    }
  }
  return postset;
}

export function isFirable(net: Net, transition: NetNode): boolean {
  if (transition.type !== 'transition') return false;
  
  const preset = getPreset(net, transition);
  for (const place of preset) {
    const placeNode = place as Place;
    const weight = getEdgeWeight(net.edges, place, transition);
    if ((placeNode.tokens || 0) < weight) {
      return false;
    }
  }
  return true;
}

export function fireTransition(net: Net, transition: NetNode): Net {
  if (!isFirable(net, transition)) return net;
  
  let newNet = { ...net };
  const preset = getPreset(net, transition);
  const postset = getPostset(net, transition);
  
  // Remove tokens from preset places
  for (const place of preset) {
    const weight = getEdgeWeight(net.edges, place, transition);
    const updatedPlace = { 
      ...place, 
      tokens: Math.max(0, (place.tokens || 0) - weight) 
    } as Place;
    newNet = updateNode(newNet, updatedPlace);
  }
  
  // Add tokens to postset places
  for (const place of postset) {
    const weight = getEdgeWeight(net.edges, transition, place);
    const updatedPlace = { 
      ...place, 
      tokens: (place.tokens || 0) + weight 
    } as Place;
    newNet = updateNode(newNet, updatedPlace);
  }
  
  return newNet;
}

// Transition system specific operations
export function getInitState(net: Net): NetNode | null {
  if (net.type !== 'lts') return null;
  
  const initNode = net.nodes.find(node => node.type === 'initState');
  if (!initNode) return null;
  
  const postset = getPostset(net, initNode);
  return postset[0] || null;
}

export function setInitState(net: Net, state: NetNode): Net {
  if (net.type !== 'lts' || state.type !== 'state') return net;
  
  let newNet = { ...net };
  
  // Remove existing init state
  newNet.nodes = net.nodes.filter(node => node.type !== 'initState');
  newNet.edges = net.edges.filter(edge => edge.type !== 'tsInitEdge');
  
  // Add new init state
  const initState = createInitState({ x: state.x - 50, y: state.y });
  newNet = addNode(newNet, initState);
  
  // Add edge from init state to target state
  const initEdge = createTsInitEdge({ source: initState, target: state });
  newNet = addEdge(newNet, initEdge);
  
  return newNet;
}

// Utility functions
export function getMaxNodeId(net: Net): number {
  return net.nodes.reduce((max, node) => Math.max(max, node.id), 0);
}

export function getMaxEdgeId(net: Net): number {
  return net.edges.reduce((max, edge) => Math.max(max, edge.id), 0);
}

export function assignNodeIds(net: Net): void {
  net.nodes.forEach((node, index) => {
    node.id = index + 1;
  });
}

export function assignEdgeIds(net: Net): void {
  net.edges.forEach((edge, index) => {
    edge.id = index + 1;
  });
}

export function getNodeByText(net: Net, text: string): NetNode | null {
  return net.nodes.find(node => getNodeText(node) === text) || null;
}

export function fixNodeReferences(net: Net): Net {
  const newNet = { ...net };
  
  // Fix edge node references
  newNet.edges = net.edges.map(edge => {
    const source = net.nodes.find(node => node.id === edge.source.id);
    const target = net.nodes.find(node => node.id === edge.target.id);
    
    if (!source || !target) {
      console.warn('Missing node reference in edge', edge.id);
      return edge;
    }
    
    return { ...edge, source, target };
  });
  
  return newNet;
}