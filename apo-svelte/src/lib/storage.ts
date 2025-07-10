import type { Net } from './types.js';
import { createSamplePetriNet, fixNodeReferences } from './nets.js';

const STORAGE_KEY = 'apo-nets';

// Storage interface
export interface NetStorage {
  nets: Net[];
  currentNetId?: string;
}

// Get nets from localStorage
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

// Save nets to localStorage
export function saveNets(nets: Net[]): void {
  try {
    const storage: NetStorage = { nets };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(storage));
  } catch (error) {
    console.error('Error saving nets to storage:', error);
  }
}

// Add a new net
export function addNet(nets: Net[], net: Net): Net[] {
  if (nets.some(existing => existing.name === net.name)) {
    console.warn('Net with this name already exists');
    return nets;
  }
  
  const newNets = [...nets, net];
  saveNets(newNets);
  return newNets;
}

// Update an existing net
export function updateNet(nets: Net[], updatedNet: Net): Net[] {
  const newNets = nets.map(net => net.id === updatedNet.id ? updatedNet : net);
  saveNets(newNets);
  return newNets;
}

// Delete a net
export function deleteNet(nets: Net[], netId: string): Net[] {
  const newNets = nets.filter(net => net.id !== netId);
  
  // Ensure at least one net exists
  if (newNets.length === 0) {
    const sampleNet = createSamplePetriNet();
    newNets.push(sampleNet);
  }
  
  saveNets(newNets);
  return newNets;
}

// Rename a net
export function renameNet(nets: Net[], netId: string, newName: string): Net[] {
  if (nets.some(net => net.name === newName && net.id !== netId)) {
    console.warn('Net with this name already exists');
    return nets;
  }
  
  const newNets = nets.map(net => 
    net.id === netId ? { ...net, name: newName } : net
  );
  
  saveNets(newNets);
  return newNets;
}

// Get net by ID
export function getNetById(nets: Net[], netId: string): Net | null {
  return nets.find(net => net.id === netId) || null;
}

// Get net by name
export function getNetByName(nets: Net[], name: string): Net | null {
  return nets.find(net => net.name === name) || null;
}

// Reset storage
export function resetStorage(): Net[] {
  localStorage.removeItem(STORAGE_KEY);
  const sampleNet = createSamplePetriNet();
  saveNets([sampleNet]);
  return [sampleNet];
}

// Validate net name
export function validateNetName(nets: Net[], name: string, excludeId?: string): string | true {
  if (!name || name.trim() === '') {
    return 'Name cannot be empty';
  }
  
  if (name.includes('"')) {
    return 'Name cannot contain quotes';
  }
  
  const exists = nets.some(net => 
    net.name === name && (!excludeId || net.id !== excludeId)
  );
  
  if (exists) {
    return 'A net with this name already exists';
  }
  
  return true;
}