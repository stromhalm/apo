import type { Tool, ToolType, Net, NetNode, NetEdge, Point, Place } from './types.js';
import { createPlace, createTransition, createState } from './nodes.js';
import { addNode, deleteNode, deleteEdge, updateNode, connectNodes, fireTransition, setInitState } from './nets.js';

// Tool definitions
export const TOOLS: Record<ToolType, Tool> = {
  move: {
    name: 'Fix Nodes',
    type: 'move',
    icon: '📍',
    description: 'Move nodes to fix their position. Double click to free them.',
    draggable: true
  },
  place: {
    name: 'Places',
    type: 'place',
    icon: '⭕',
    description: 'Create places',
    draggable: true
  },
  transition: {
    name: 'Transitions',
    type: 'transition',
    icon: '⬜',
    description: 'Create transitions',
    draggable: true
  },
  state: {
    name: 'States',
    type: 'state',
    icon: '🔵',
    description: 'Create states',
    draggable: true
  },
  arrow: {
    name: 'Arrows',
    type: 'arrow',
    icon: '↩️',
    description: 'Connect nodes in the graph via arrows',
    draggable: false
  },
  token: {
    name: 'Tokens',
    type: 'token',
    icon: '▶️',
    description: 'Set the number of tokens on places and fire transitions',
    draggable: false
  },
  delete: {
    name: 'Delete',
    type: 'delete',
    icon: '🗑️',
    description: 'Delete nodes and arrows in the graph',
    draggable: false
  },
  labels: {
    name: 'Labels',
    type: 'labels',
    icon: '🏷️',
    description: 'Label places, transitions and set edge weights',
    draggable: false
  },
  initial: {
    name: 'Initial State',
    type: 'initial',
    icon: '🎯',
    description: 'Set a state as initial state',
    draggable: false
  }
};

// Get tools for a specific net type
export function getToolsForNetType(netType: 'pn' | 'lts'): Tool[] {
  if (netType === 'pn') {
    return [
      TOOLS.move,
      TOOLS.place,
      TOOLS.transition,
      TOOLS.arrow,
      TOOLS.token,
      TOOLS.delete,
      TOOLS.labels
    ];
  } else {
    return [
      TOOLS.move,
      TOOLS.state,
      TOOLS.arrow,
      TOOLS.delete,
      TOOLS.initial,
      TOOLS.labels
    ];
  }
}

// Tool action handlers
export interface ToolActions {
  onMouseDownOnNode?: (net: Net, node: NetNode) => Net;
  onMouseUpOnNode?: (net: Net, mouseUpNode: NetNode, mouseDownNode: NetNode | null) => Net;
  onMouseDownOnEdge?: (net: Net, edge: NetEdge) => Net;
  onMouseDownOnCanvas?: (net: Net, point: Point) => Net;
  onDoubleClickOnNode?: (net: Net, node: NetNode) => Net;
}

// Move tool
export const moveToolActions: ToolActions = {
  onMouseDownOnNode: (net, node) => {
    const updatedNode = { ...node, fixed: true };
    return updateNode(net, updatedNode);
  },
  onDoubleClickOnNode: (net, node) => {
    const updatedNode = { ...node, fixed: false };
    return updateNode(net, updatedNode);
  }
};

// Place tool
export const placeToolActions: ToolActions = {
  onMouseDownOnCanvas: (net, point) => {
    if (net.type !== 'pn') return net;
    const place = createPlace(point);
    return addNode(net, place);
  }
};

// Transition tool
export const transitionToolActions: ToolActions = {
  onMouseDownOnCanvas: (net, point) => {
    if (net.type !== 'pn') return net;
    const transition = createTransition(point);
    return addNode(net, transition);
  }
};

// State tool
export const stateToolActions: ToolActions = {
  onMouseDownOnCanvas: (net, point) => {
    if (net.type !== 'lts') return net;
    const state = createState(point);
    return addNode(net, state);
  }
};

// Arrow tool - handled by drag interactions in the canvas component

// Token tool
export const tokenToolActions: ToolActions = {
  onMouseDownOnNode: (net, node) => {
    if (node.type === 'place') {
      // Token setting will be handled by a dialog
      return net;
    } else if (node.type === 'transition') {
      return fireTransition(net, node);
    }
    return net;
  }
};

// Delete tool
export const deleteToolActions: ToolActions = {
  onMouseDownOnNode: (net, node) => deleteNode(net, node),
  onMouseDownOnEdge: (net, edge) => deleteEdge(net, edge)
};

// Labels tool - handled by dialogs

// Initial state tool
export const initialStateToolActions: ToolActions = {
  onMouseDownOnNode: (net, node) => {
    if (net.type === 'lts' && node.type === 'state') {
      return setInitState(net, node);
    }
    return net;
  }
};

// Get tool actions
export function getToolActions(toolType: ToolType): ToolActions {
  switch (toolType) {
    case 'move': return moveToolActions;
    case 'place': return placeToolActions;
    case 'transition': return transitionToolActions;
    case 'state': return stateToolActions;
    case 'token': return tokenToolActions;
    case 'delete': return deleteToolActions;
    case 'initial': return initialStateToolActions;
    default: return {};
  }
}

// Tool validation
export function isToolValidForNet(toolType: ToolType, netType: 'pn' | 'lts'): boolean {
  const tools = getToolsForNetType(netType);
  return tools.some(tool => tool.type === toolType);
}

// Get default tool for net type
export function getDefaultTool(netType: 'pn' | 'lts'): ToolType {
  return 'move';
}