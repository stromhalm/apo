import type { Net, NetNode, Place, Transition, State } from './types.js';
import { createPetriNet, createTransitionSystem, addNode, addEdge, setInitState, getNodeByText } from './nets.js';
import { createPlace, createTransition, createState, getNodeText } from './nodes.js';
import { createPnEdge, createTsEdge } from './edges.js';

// Export net to APT format
export function exportToApt(net: Net): string {
  const lines: string[] = [];
  
  lines.push(`.name "${net.name}"`);
  
  if (net.type === 'lts') {
    lines.push('.type LTS');
    lines.push('');
    
    // Add states
    lines.push('.states');
    const initState = getInitState(net);
    
    for (const node of net.nodes) {
      if (node.type === 'state') {
        const stateText = getNodeText(node);
        const isInitial = initState && initState.id === node.id;
        lines.push(stateText + (isInitial ? '[initial]' : ''));
      }
    }
    lines.push('');
    
    // Add labels
    lines.push('.labels');
    const labels = new Set<string>();
    
    for (const edge of net.edges) {
      if (edge.type === 'tsEdge') {
        const tsEdge = edge as any;
        if (edge.left >= 1 && tsEdge.labelsLeft) {
          tsEdge.labelsLeft.forEach((label: string) => labels.add(label));
        }
        if (edge.right >= 1 && tsEdge.labelsRight) {
          tsEdge.labelsRight.forEach((label: string) => labels.add(label));
        }
      }
    }
    
    for (const node of net.nodes) {
      if (node.type === 'state') {
        const state = node as State;
        if (state.labelsToSelf) {
          state.labelsToSelf.forEach(label => labels.add(label));
        }
      }
    }
    
    Array.from(labels).forEach(label => lines.push(label));
    lines.push('');
    
    // Add arcs
    lines.push('.arcs');
    
    // Self-loops
    for (const node of net.nodes) {
      if (node.type === 'state') {
        const state = node as State;
        const stateText = getNodeText(state);
        if (state.labelsToSelf) {
          state.labelsToSelf.forEach(label => {
            lines.push(`${stateText} ${label} ${stateText}`);
          });
        }
      }
    }
    
    // Regular edges
    for (const edge of net.edges) {
      if (edge.type === 'tsEdge') {
        const tsEdge = edge as any;
        const sourceText = getNodeText(edge.source);
        const targetText = getNodeText(edge.target);
        
        if (edge.left >= 1 && tsEdge.labelsLeft) {
          tsEdge.labelsLeft.forEach((label: string) => {
            lines.push(`${targetText} ${label} ${sourceText}`);
          });
        }
        
        if (edge.right >= 1 && tsEdge.labelsRight) {
          tsEdge.labelsRight.forEach((label: string) => {
            lines.push(`${sourceText} ${label} ${targetText}`);
          });
        }
      }
    }
    
  } else if (net.type === 'pn') {
    lines.push('.type PN');
    lines.push('');
    
    // Add places
    lines.push('.places');
    for (const node of net.nodes) {
      if (node.type === 'place') {
        lines.push(getNodeText(node));
      }
    }
    lines.push('');
    
    // Add transitions
    lines.push('.transitions');
    for (const node of net.nodes) {
      if (node.type === 'transition') {
        lines.push(getNodeText(node));
      }
    }
    lines.push('');
    
    // Add flows
    lines.push('.flows');
    for (const node of net.nodes) {
      if (node.type === 'transition') {
        const transitionText = getNodeText(node);
        const preset = getPreset(net, node);
        const postset = getPostset(net, node);
        
        let line = `${transitionText}: {`;
        
        // Preset
        const presetParts: string[] = [];
        preset.forEach(place => {
          const weight = getEdgeWeight(net, place, node);
          const placeText = getNodeText(place);
          presetParts.push(`${weight}*${placeText}`);
        });
        line += presetParts.join(', ');
        
        line += '} -> {';
        
        // Postset
        const postsetParts: string[] = [];
        postset.forEach(place => {
          const weight = getEdgeWeight(net, node, place);
          const placeText = getNodeText(place);
          postsetParts.push(`${weight}*${placeText}`);
        });
        line += postsetParts.join(', ');
        
        line += '}';
        lines.push(line);
      }
    }
    lines.push('');
    
    // Add initial marking
    const placesWithTokens = net.nodes.filter(node => 
      node.type === 'place' && (node as Place).tokens > 0
    ) as Place[];
    
    if (placesWithTokens.length > 0) {
      let line = '.initial_marking {';
      const markingParts = placesWithTokens.map(place => {
        const placeText = getNodeText(place);
        return `${place.tokens}*${placeText}`;
      });
      line += markingParts.join(', ');
      line += '}';
      lines.push(line);
    } else {
      lines.push('.initial_marking {}');
    }
  }
  
  return lines.join('\n');
}

// Import net from APT format
export function importFromApt(aptCode: string): Net | null {
  try {
    const name = getAptBlock('name', aptCode)?.split('"')[1];
    if (!name) throw new Error('Invalid APT format: missing name');
    
    const typeBlock = getAptBlock('type', aptCode);
    
    if (typeBlock?.includes('LTS')) {
      return importLtsFromApt(name, aptCode);
    } else if (typeBlock?.includes('PN')) {
      return importPnFromApt(name, aptCode);
    }
    
    throw new Error('Invalid APT format: unknown type');
  } catch (error) {
    console.error('Error importing APT:', error);
    return null;
  }
}

// Import LTS from APT
function importLtsFromApt(name: string, aptCode: string): Net {
  const net = createTransitionSystem(name);
  
  // Add states
  const states = getAptBlockRows('states', aptCode);
  let initialStateText: string | null = null;
  
  for (const stateRow of states) {
    let stateLabel = stateRow.split(' ')[0];
    let isInitial = false;
    
    if (stateLabel.includes('[initial]') || stateLabel.includes('[initial="true"]')) {
      isInitial = true;
      stateLabel = stateLabel.replace(/\[initial.*?\]/g, '');
      initialStateText = stateLabel;
    }
    
    const state = createState({ x: Math.random() * 400 + 100, y: Math.random() * 300 + 100, label: stateLabel });
    net.nodes.push(state);
  }
  
  // Assign IDs
  net.nodes.forEach((node, index) => node.id = index + 1);
  
  // Set initial state
  if (initialStateText) {
    const initialState = getNodeByText(net, initialStateText);
    if (initialState) {
      const updatedNet = setInitState(net, initialState);
      net.nodes = updatedNet.nodes;
      net.edges = updatedNet.edges;
    }
  }
  
  // Add edges
  const arcs = getAptBlockRows('arcs', aptCode);
  for (const arcRow of arcs) {
    const parts = arcRow.split(' ');
    if (parts.length >= 3) {
      const sourceText = parts[0];
      const label = parts[1];
      const targetText = parts[2];
      
      const source = getNodeByText(net, sourceText);
      const target = getNodeByText(net, targetText);
      
      if (source && target) {
        if (source.id === target.id) {
          // Self-loop
          const state = source as State;
          if (!state.labelsToSelf) state.labelsToSelf = [];
          state.labelsToSelf.push(label);
        } else {
          // Regular edge
          let edge = net.edges.find(e => 
            (e.source.id === source.id && e.target.id === target.id) ||
            (e.source.id === target.id && e.target.id === source.id)
          );
          
          if (!edge) {
            edge = createTsEdge({ 
              source, 
              target, 
              right: 1, 
              labelsRight: [label],
              id: net.edges.length + 1
            });
            net.edges.push(edge);
          } else {
            const tsEdge = edge as any;
            if (edge.source.id === source.id) {
              edge.right = 1;
              if (!tsEdge.labelsRight) tsEdge.labelsRight = [];
              tsEdge.labelsRight.push(label);
            } else {
              edge.left = 1;
              if (!tsEdge.labelsLeft) tsEdge.labelsLeft = [];
              tsEdge.labelsLeft.push(label);
            }
          }
        }
      }
    }
  }
  
  return net;
}

// Import PN from APT
function importPnFromApt(name: string, aptCode: string): Net {
  const net = createPetriNet(name);
  
  // Add places
  const places = getAptBlockRows('places', aptCode);
  for (const placeLabel of places) {
    const place = createPlace({ 
      x: Math.random() * 400 + 100, 
      y: Math.random() * 300 + 100, 
      label: placeLabel,
      tokens: 0
    });
    net.nodes.push(place);
  }
  
  // Add transitions
  const transitions = getAptBlockRows('transitions', aptCode);
  for (const transitionLabel of transitions) {
    const transition = createTransition({ 
      x: Math.random() * 400 + 100, 
      y: Math.random() * 300 + 100, 
      label: transitionLabel
    });
    net.nodes.push(transition);
  }
  
  // Assign IDs
  net.nodes.forEach((node, index) => node.id = index + 1);
  
  // Add flows (edges)
  const flows = getAptBlockRows('flows', aptCode);
  for (const flowRow of flows) {
    const transitionName = flowRow.split(':')[0].trim();
    const transition = getNodeByText(net, transitionName);
    
    if (transition) {
      const preset = extractFlowSet(flowRow, ':', '} ->');
      const postset = extractFlowSet(flowRow, '-> {', '}');
      
      // Add preset edges
      preset.forEach(({ weight, placeName }) => {
        const place = getNodeByText(net, placeName);
        if (place) {
          const edge = createPnEdge({ 
            source: place, 
            target: transition, 
            right: weight,
            id: net.edges.length + 1
          });
          net.edges.push(edge);
        }
      });
      
      // Add postset edges
      postset.forEach(({ weight, placeName }) => {
        const place = getNodeByText(net, placeName);
        if (place) {
          const edge = createPnEdge({ 
            source: transition, 
            target: place, 
            right: weight,
            id: net.edges.length + 1
          });
          net.edges.push(edge);
        }
      });
    }
  }
  
  // Set initial marking
  const markingBlock = getAptBlock('initial_marking', aptCode);
  if (markingBlock) {
    const markingContent = markingBlock.match(/\{(.*?)\}/)?.[1];
    if (markingContent) {
      const markings = markingContent.split(',').map(s => s.trim()).filter(s => s);
      for (const marking of markings) {
        const match = marking.match(/(\d+)\*(.+)/);
        if (match) {
          const tokens = parseInt(match[1]);
          const placeName = match[2].trim();
          const place = getNodeByText(net, placeName) as Place;
          if (place) {
            place.tokens = tokens;
          }
        }
      }
    }
  }
  
  return net;
}

// Helper functions
function getAptBlock(blockName: string, aptCode: string): string | null {
  const regex = new RegExp(`\\.${blockName}\\s+([^\\n]*)`);
  const match = aptCode.match(regex);
  return match ? match[1] : null;
}

function getAptBlockRows(blockName: string, aptCode: string): string[] {
  const lines = aptCode.split('\n');
  const startRegex = new RegExp(`^\\.${blockName}\\s*$`);
  
  let startIndex = -1;
  for (let i = 0; i < lines.length; i++) {
    if (startRegex.test(lines[i].trim())) {
      startIndex = i + 1;
      break;
    }
  }
  
  if (startIndex === -1) return [];
  
  const rows: string[] = [];
  for (let i = startIndex; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line || line.startsWith('.')) break;
    rows.push(line);
  }
  
  return rows;
}

function extractFlowSet(flowRow: string, startMarker: string, endMarker: string): Array<{ weight: number, placeName: string }> {
  const start = flowRow.indexOf(startMarker);
  const end = flowRow.indexOf(endMarker, start);
  
  if (start === -1 || end === -1) return [];
  
  const content = flowRow.substring(start + startMarker.length, end).trim();
  if (!content || content === '{}') return [];
  
  return content.split(',').map(item => {
    const trimmed = item.trim();
    const match = trimmed.match(/(\d+)\*(.+)/);
    if (match) {
      return {
        weight: parseInt(match[1]),
        placeName: match[2].trim()
      };
    }
    return { weight: 1, placeName: trimmed };
  }).filter(item => item.placeName);
}

// Helper functions that reference net operations
function getInitState(net: Net): NetNode | null {
  if (net.type !== 'lts') return null;
  const initNode = net.nodes.find(node => node.type === 'initState');
  if (!initNode) return null;
  return getPostset(net, initNode)[0] || null;
}

function getPreset(net: Net, node: NetNode): NetNode[] {
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

function getPostset(net: Net, node: NetNode): NetNode[] {
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

function getEdgeWeight(net: Net, source: NetNode, target: NetNode): number {
  for (const edge of net.edges) {
    if (edge.source.id === source.id && edge.target.id === target.id) {
      return edge.right;
    } else if (edge.source.id === target.id && edge.target.id === source.id) {
      return edge.left;
    }
  }
  return 0;
}