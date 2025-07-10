import type { NetEdge, PnEdge, TsEdge, TsInitEdge, NetNode } from './types.js';

// Edge creation functions
export function createPnEdge(options: {
  source: NetNode;
  target: NetNode;
  left?: number;
  right?: number;
  id?: number;
}): PnEdge {
  return {
    type: 'pnEdge',
    id: options.id || 0,
    source: options.source,
    target: options.target,
    left: options.left || 0,
    right: options.right || 0,
    length: 150
  };
}

export function createTsEdge(options: {
  source: NetNode;
  target: NetNode;
  left?: number;
  right?: number;
  labelsLeft?: string[];
  labelsRight?: string[];
  id?: number;
}): TsEdge {
  return {
    type: 'tsEdge',
    id: options.id || 0,
    source: options.source,
    target: options.target,
    left: options.left || 0,
    right: options.right || 0,
    labelsLeft: options.labelsLeft || [],
    labelsRight: options.labelsRight || [],
    length: 150
  };
}

export function createTsInitEdge(options: {
  source: NetNode;
  target: NetNode;
  id?: number;
}): TsInitEdge {
  return {
    type: 'tsInitEdge',
    id: options.id || 0,
    source: options.source,
    target: options.target,
    left: 0,
    right: 1,
    length: 150
  };
}

// Edge utility functions
export function getEdgeText(edge: NetEdge): string {
  if (edge.type === 'pnEdge') {
    const pnEdge = edge as PnEdge;
    if (pnEdge.left >= 1 && pnEdge.right >= 1) {
      return `← ${pnEdge.left} | ${pnEdge.right} →`;
    } else if (pnEdge.left >= 2) {
      return pnEdge.left.toString();
    } else if (pnEdge.right >= 2) {
      return pnEdge.right.toString();
    }
  } else if (edge.type === 'tsEdge') {
    const tsEdge = edge as TsEdge;
    const labels: string[] = [];
    if (tsEdge.left >= 1 && tsEdge.labelsLeft.length > 0) {
      labels.push(...tsEdge.labelsLeft.map(label => `← ${label}`));
    }
    if (tsEdge.right >= 1 && tsEdge.labelsRight.length > 0) {
      labels.push(...tsEdge.labelsRight.map(label => `${label} →`));
    }
    return labels.join(', ');
  }
  return '';
}

export function getEdgePath(edge: NetEdge): string {
  const deltaX = edge.target.x - edge.source.x;
  const deltaY = edge.target.y - edge.source.y;
  const dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
  
  if (dist === 0) return '';
  
  const normX = deltaX / dist;
  const normY = deltaY / dist;
  const sourcePadding = edge.left >= 1 ? edge.source.radius + 5 : edge.source.radius;
  const targetPadding = edge.right >= 1 ? edge.target.radius + 5 : edge.target.radius;

  const sourceX = edge.source.x + sourcePadding * normX;
  const sourceY = edge.source.y + sourcePadding * normY;
  const targetX = edge.target.x - targetPadding * normX;
  const targetY = edge.target.y - targetPadding * normY;
  
  return `M${sourceX},${sourceY}L${targetX},${targetY}`;
}

// Edge finding utilities
export function findEdge(
  edges: NetEdge[], 
  source: NetNode, 
  target: NetNode, 
  direction: 'forward' | 'backward' = 'forward'
): NetEdge | undefined {
  if (direction === 'forward') {
    return edges.find(edge => edge.source.id === source.id && edge.target.id === target.id);
  } else {
    return edges.find(edge => edge.source.id === target.id && edge.target.id === source.id);
  }
}

export function getEdgeWeight(edges: NetEdge[], source: NetNode, target: NetNode): number {
  for (const edge of edges) {
    if (edge.source.id === source.id && edge.target.id === target.id) {
      return edge.right;
    } else if (edge.source.id === target.id && edge.target.id === source.id) {
      return edge.left;
    }
  }
  return 0;
}