// Core geometric types
export interface Point {
  x: number;
  y: number;
}

// Node types
export type NodeType = 'place' | 'transition' | 'state' | 'initState';
export type NetType = 'pn' | 'lts';
export type ToolType = 'move' | 'place' | 'transition' | 'state' | 'arrow' | 'token' | 'delete' | 'labels' | 'initial';

// Base node interface
export interface NetNode extends Point {
  id: number;
  type: NodeType;
  label: string;
  radius: number;
  fixed?: boolean;
  tokens?: number; // For places
  labelsToSelf?: string[]; // For states
  connectableTypes: NodeType[];
}

// Specific node types
export interface Place extends NetNode {
  type: 'place';
  tokens: number;
  connectableTypes: ['transition'];
}

export interface Transition extends NetNode {
  type: 'transition';
  connectableTypes: ['place'];
}

export interface State extends NetNode {
  type: 'state';
  labelsToSelf: string[];
  connectableTypes: ['state'];
}

export interface InitState extends NetNode {
  type: 'initState';
  connectableTypes: ['state'];
}

// Edge types
export interface NetEdge {
  id: number;
  source: NetNode;
  target: NetNode;
  type: 'pnEdge' | 'tsEdge' | 'tsInitEdge';
  left: number;
  right: number;
  length: number;
}

export interface PnEdge extends NetEdge {
  type: 'pnEdge';
}

export interface TsEdge extends NetEdge {
  type: 'tsEdge';
  labelsLeft: string[];
  labelsRight: string[];
}

export interface TsInitEdge extends NetEdge {
  type: 'tsInitEdge';
}

// Tool interface
export interface Tool {
  name: string;
  type: ToolType;
  icon: string;
  description: string;
  draggable: boolean;
}

// Net interface
export interface Net {
  id: string;
  name: string;
  type: NetType;
  nodes: NetNode[];
  edges: NetEdge[];
  activeTool: ToolType;
}

// Analyzer interface
export interface Analyzer {
  name: string;
  icon: string;
  description: string;
  offlineCapable: boolean;
}

// Form dialog types
export interface FormElement {
  name: string;
  type: 'text' | 'number' | 'textArray' | 'checkbox' | 'code' | 'file';
  value?: any;
  min?: number;
  validation?: (value: any) => string | boolean;
  showIf?: (formElements: FormElement[]) => boolean;
}