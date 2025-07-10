import type { NetNode, Place, Transition, State, InitState, Point } from './types.js';

// Node creation functions
export function createPlace(options: Partial<Place> & Point): Place {
  return {
    type: 'place',
    id: options.id || 0,
    x: options.x,
    y: options.y,
    label: options.label || '',
    radius: 18,
    tokens: options.tokens || 0,
    connectableTypes: ['transition'],
    fixed: options.fixed || false
  };
}

export function createTransition(options: Partial<Transition> & Point): Transition {
  return {
    type: 'transition',
    id: options.id || 0,
    x: options.x,
    y: options.y,
    label: options.label || '',
    radius: 18,
    connectableTypes: ['place'],
    fixed: options.fixed || false
  };
}

export function createState(options: Partial<State> & Point): State {
  return {
    type: 'state',
    id: options.id || 0,
    x: options.x,
    y: options.y,
    label: options.label || '',
    radius: 18,
    labelsToSelf: options.labelsToSelf || [],
    connectableTypes: ['state'],
    fixed: options.fixed || false
  };
}

export function createInitState(options: Partial<InitState> & Point): InitState {
  return {
    type: 'initState',
    id: options.id || 0,
    x: options.x,
    y: options.y,
    label: options.label || '',
    radius: 18,
    labelsToSelf: [],
    connectableTypes: ['state'],
    fixed: options.fixed || false
  };
}

// Node utility functions
export function getNodeText(node: NetNode): string {
  return node.label || node.id.toString();
}

export function getTokenLabel(node: NetNode): string {
  if (node.type === 'place') {
    const place = node as Place;
    return place.tokens > 0 ? place.tokens.toString() : '';
  }
  return '';
}

export function getSelfEdgePath(node: NetNode): string {
  if (node.type === 'state') {
    const radius = node.radius;
    return `M 0,-${radius} C 0,-${radius * 5} ${radius * 5},0 ${radius + 5},0`;
  }
  return '';
}

export function getSelfEdgeText(node: NetNode): string {
  if (node.type === 'state') {
    const state = node as State;
    return state.labelsToSelf.join(', ');
  }
  return '';
}

export function isConnectable(source: NetNode, target: NetNode): boolean {
  return source.connectableTypes.includes(target.type);
}

// Node validation
export function validateLabel(labelName: string): string | boolean {
  if (labelName.includes('*')) return "Labels can't contain '*'";
  if (labelName.includes(',')) return "Labels can't contain ','";
  if (labelName.includes(' ')) return "Labels can't contain spaces";
  if (labelName.includes('{')) return "Labels can't contain '{'";
  if (labelName.includes('}')) return "Labels can't contain '}'";
  return true;
}