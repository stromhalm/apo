# APO - Complete SvelteKit Rewrite Implementation

## Overview

This document outlines the complete rewrite of the APO (APT Online) petri net editor from Angular 1.x + CoffeeScript to SvelteKit + Svelte 5 + TypeScript. The rewrite maintains all original functionality while modernizing the codebase with functional programming approaches and modern web technologies.

## Project Structure

```
apo-svelte/
├── src/
│   ├── lib/
│   │   ├── types.ts              # Core TypeScript interfaces
│   │   ├── nodes.ts              # Functional node operations
│   │   ├── edges.ts              # Functional edge operations
│   │   ├── nets.ts               # Net management and analysis
│   │   ├── tools.ts              # Editor tools system
│   │   ├── storage.ts            # Local storage utilities
│   │   ├── apt.ts                # APT format import/export
│   │   └── components/           # Svelte components
│   │       ├── Sidebar.svelte    # Net management sidebar
│   │       ├── TopBar.svelte     # Application header
│   │       ├── MenuBar.svelte    # File/analyze menus
│   │       ├── ToolBar.svelte    # Editor tools
│   │       └── EditorCanvas.svelte # Main editor with D3.js
│   ├── routes/
│   │   ├── +layout.svelte        # App layout
│   │   └── +page.svelte          # Main page
│   └── app.css                   # Tailwind styles
├── static/                       # Static assets
└── package.json                  # Dependencies
```

## Key Architectural Changes

### 1. Functional vs Object-Oriented Approach

**Before (CoffeeScript OOP):**
```coffeescript
class @PetriNet extends @Net
  constructor: (netObject) ->
    super(netObject)
    @type = "pn"
  
  addTransition: (point) ->
    transition = new Transition(point)
    @addNode(transition)
```

**After (TypeScript Functional):**
```typescript
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

export function addNode(net: Net, node: NetNode): Net {
  const newNet = { ...net };
  newNet.nodes = [...net.nodes, { ...node, id: getMaxNodeId(net) + 1 }];
  return newNet;
}
```

### 2. Modern TypeScript Types

Comprehensive type system replacing dynamic CoffeeScript:

```typescript
// Core geometric types
export interface Point {
  x: number;
  y: number;
}

// Node types with proper inheritance
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

// Specific implementations
export interface Place extends NetNode {
  type: 'place';
  tokens: number;
  connectableTypes: ['transition'];
}
```

### 3. Immutable State Management

All operations return new state rather than mutating existing objects:

```typescript
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
```

## Core Features Implemented

### 1. Petri Net and Transition System Support

- **Petri Nets**: Places, transitions, tokens, weighted edges
- **Transition Systems**: States, labeled transitions, initial states
- **Net Operations**: Add/delete nodes, connect nodes, fire transitions
- **Analysis**: Preset/postset calculation, transition firing logic

### 2. Editor Tools System

Functional tool system with composable actions:

```typescript
export interface ToolActions {
  onMouseDownOnNode?: (net: Net, node: NetNode) => Net;
  onMouseUpOnNode?: (net: Net, mouseUpNode: NetNode, mouseDownNode: NetNode | null) => Net;
  onMouseDownOnEdge?: (net: Net, edge: NetEdge) => Net;
  onMouseDownOnCanvas?: (net: Net, point: Point) => Net;
  onDoubleClickOnNode?: (net: Net, node: NetNode) => Net;
}
```

**Available Tools:**
- **Move Tool**: Fix/unfix node positions
- **Place Tool**: Create places (PN only)
- **Transition Tool**: Create transitions (PN only)  
- **State Tool**: Create states (LTS only)
- **Arrow Tool**: Connect nodes with edges
- **Token Tool**: Set tokens and fire transitions
- **Delete Tool**: Remove nodes and edges
- **Labels Tool**: Edit labels and weights
- **Initial State Tool**: Set initial state (LTS only)

### 3. Local Storage Persistence

Browser-based storage with automatic saving:

```typescript
export function saveNets(nets: Net[]): void {
  try {
    const storage: NetStorage = { nets };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(storage));
  } catch (error) {
    console.error('Error saving nets to storage:', error);
  }
}

export function loadNets(): Net[] {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) {
      const sampleNet = createSamplePetriNet();
      saveNets([sampleNet]);
      return [sampleNet];
    }
    
    const storage: NetStorage = JSON.parse(stored);
    return storage.nets.map(net => fixNodeReferences(net));
  } catch (error) {
    console.error('Error loading nets from storage:', error);
    const sampleNet = createSamplePetriNet();
    saveNets([sampleNet]);
    return [sampleNet];
  }
}
```

### 4. APT Format Import/Export

Complete APT format support for both Petri nets and transition systems:

```typescript
export function exportToApt(net: Net): string {
  const lines: string[] = [];
  lines.push(`.name "${net.name}"`);
  
  if (net.type === 'lts') {
    lines.push('.type LTS');
    // ... LTS export logic
  } else if (net.type === 'pn') {
    lines.push('.type PN');
    // ... PN export logic
  }
  
  return lines.join('\n');
}

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
```

### 5. Modern UI with Tailwind CSS

Complete redesign using Tailwind CSS for modern, responsive interface:

- **Sidebar**: Net management with create/delete functionality
- **TopBar**: Application header with navigation
- **MenuBar**: File operations and analysis tools
- **ToolBar**: Editor tool selection
- **Canvas**: D3.js-powered interactive editor

### 6. Physics Simulation with D3.js

The original D3.js force simulation is preserved and enhanced:

```typescript
// Physics parameters
const charge = -500;
const linkStrength = 0.1;
const friction = 0.9;
const gravity = 0.1;

// D3 force layout setup
force = d3.layout.force()
  .nodes(net.nodes)
  .links(net.edges)
  .size([width, height])
  .linkDistance(edge => edge.length)
  .linkStrength(linkStrength)
  .friction(friction)
  .charge(charge)
  .gravity(gravity)
  .on('tick', tick);
```

## Component Architecture

### Main Application (`+page.svelte`)

Central state management and component coordination:

```svelte
<script lang="ts">
  import { onMount } from 'svelte';
  import type { Net } from '$lib/types.js';
  import { loadNets, updateNet } from '$lib/storage.js';
  
  let nets: Net[] = [];
  let currentNet: Net | null = null;
  let sidebarOpen = true;

  function handleNetUpdate(updatedNet: Net) {
    nets = nets.map(net => net.id === updatedNet.id ? updatedNet : net);
    currentNet = updatedNet;
    updateNet(nets, updatedNet);
  }
</script>

<div class="flex h-full w-full bg-gray-50">
  <!-- Sidebar, TopBar, MenuBar, ToolBar, Canvas components -->
</div>
```

### Sidebar Component (`Sidebar.svelte`)

Net management with modern UI:

- List all nets with metadata
- Create new nets (PN/LTS)
- Delete nets with confirmation
- Visual indicators for current selection
- Responsive design

### Editor Canvas Component (`EditorCanvas.svelte`)

Core editor with D3.js integration:

- SVG-based rendering
- Force-directed physics simulation
- Interactive node and edge manipulation
- Tool-specific behaviors
- Real-time updates

## Migration Benefits

### 1. Performance Improvements

- **Faster rendering**: Modern Svelte compilation
- **Smaller bundle**: No Angular/jQuery dependencies
- **Better memory management**: Immutable state patterns
- **Optimized updates**: Svelte's reactive system

### 2. Developer Experience

- **Type safety**: Full TypeScript coverage
- **Modern tooling**: Vite, SvelteKit, TypeScript
- **Functional patterns**: Easier testing and reasoning
- **Better structure**: Clear separation of concerns

### 3. Maintainability

- **Modular design**: Composable functions and components
- **Clear interfaces**: Well-defined TypeScript types
- **Immutable state**: Predictable data flow
- **Modern practices**: Current web development standards

### 4. User Experience

- **Responsive design**: Works on all devices
- **Modern UI**: Clean, intuitive interface
- **Better performance**: Faster loading and interactions
- **Accessibility**: Proper ARIA labels and keyboard navigation

## Technology Stack

### Frontend Framework
- **SvelteKit**: Full-stack framework with SSG
- **Svelte 5**: Modern reactive UI library
- **TypeScript**: Static typing for reliability

### Styling
- **Tailwind CSS**: Utility-first CSS framework
- **PostCSS**: CSS processing pipeline
- **Responsive design**: Mobile-first approach

### Libraries
- **D3.js**: Data visualization and physics simulation
- **UUID**: Unique identifier generation
- **Standard web APIs**: LocalStorage, File API

### Development Tools
- **Vite**: Fast build tool and dev server
- **TypeScript**: Type checking and compilation
- **ESLint**: Code linting and standards
- **Modern browser targets**: ES2022+

## Deployment

The application builds to a fully static site:

```bash
npm run build
```

Generates optimized static files for deployment to any static hosting service:
- Netlify
- Vercel
- GitHub Pages
- Any CDN or web server

## Future Enhancements

### Planned Features
1. **Cloud storage integration**
2. **Collaborative editing**
3. **Advanced analysis tools**
4. **Plugin system**
5. **Export to image formats**
6. **Undo/redo functionality**
7. **Keyboard shortcuts**
8. **Theme customization**

### Technical Improvements
1. **WebAssembly for analysis**
2. **Web Workers for heavy computations**
3. **IndexedDB for large datasets**
4. **PWA capabilities**
5. **Real-time collaboration**

## Conclusion

The complete rewrite successfully modernizes APO while maintaining all original functionality. The new architecture provides a solid foundation for future enhancements while delivering improved performance, maintainability, and user experience.

The functional approach and immutable state management make the codebase more predictable and easier to reason about, while TypeScript provides the type safety needed for a complex application like a petri net editor.

The modern UI built with Tailwind CSS offers a clean, responsive experience that works well on both desktop and mobile devices, representing a significant improvement over the original Material Design implementation.