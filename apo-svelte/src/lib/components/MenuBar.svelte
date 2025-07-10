<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Net } from '$lib/types.js';
  import { exportToApt, importFromApt } from '$lib/apt.js';
  import { addNet, renameNet, deleteNet as deleteNetFromStorage, validateNetName } from '$lib/storage.js';
  import { createPetriNet, createTransitionSystem } from '$lib/nets.js';

  export let nets: Net[];
  export let currentNet: Net;

  const dispatch = createEventDispatcher<{
    netUpdate: Net;
    netsUpdate: Net[];
  }>();

  // File operations
  function exportNet() {
    const aptCode = exportToApt(currentNet);
    const blob = new Blob([aptCode], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `${currentNet.name}.apt`;
    a.click();
    
    URL.revokeObjectURL(url);
  }

  function importNet() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.apt';
    
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (!file) return;
      
      const reader = new FileReader();
      reader.onload = (event) => {
        const aptCode = event.target?.result as string;
        const importedNet = importFromApt(aptCode);
        
        if (importedNet) {
          // Check for name conflicts
          const validation = validateNetName(nets, importedNet.name);
          if (validation !== true) {
            const newName = prompt(`${validation}\nEnter a new name:`, `${importedNet.name}_imported`);
            if (newName) {
              importedNet.name = newName;
            } else {
              return;
            }
          }
          
          const updatedNets = addNet(nets, importedNet);
          dispatch('netsUpdate', updatedNets);
          dispatch('netUpdate', importedNet);
        } else {
          alert('Failed to import net. Please check the APT format.');
        }
      };
      
      reader.readAsText(file);
    };
    
    input.click();
  }

  function createNewNet(type: 'pn' | 'lts') {
    const name = prompt(`Enter name for new ${type === 'pn' ? 'Petri Net' : 'Transition System'}:`);
    if (!name) return;
    
    const validation = validateNetName(nets, name);
    if (validation !== true) {
      alert(validation);
      return;
    }
    
    const newNet = type === 'pn' ? createPetriNet(name) : createTransitionSystem(name);
    const updatedNets = addNet(nets, newNet);
    dispatch('netsUpdate', updatedNets);
    dispatch('netUpdate', newNet);
  }

  function handleRenameNet() {
    const newName = prompt('Enter new name:', currentNet.name);
    if (!newName || newName === currentNet.name) return;
    
    const validation = validateNetName(nets, newName, currentNet.id);
    if (validation !== true) {
      alert(validation);
      return;
    }
    
    const updatedNets = renameNet(nets, currentNet.id, newName);
    dispatch('netsUpdate', updatedNets);
    
    const updatedNet = { ...currentNet, name: newName };
    dispatch('netUpdate', updatedNet);
  }

  function handleDeleteNet() {
    if (confirm(`Do you really want to delete the net '${currentNet.name}'?`)) {
      const updatedNets = deleteNetFromStorage(nets, currentNet.id);
      dispatch('netsUpdate', updatedNets);
    }
  }

  function showNetInfo() {
    const info = `Net Information:

Name: ${currentNet.name}
Type: ${currentNet.type === 'pn' ? 'Petri Net' : 'Transition System'}
Nodes: ${currentNet.nodes.length}
Edges: ${currentNet.edges.length}
Active Tool: ${currentNet.activeTool}

${currentNet.type === 'pn' ? 
  `Places: ${currentNet.nodes.filter(n => n.type === 'place').length}
Transitions: ${currentNet.nodes.filter(n => n.type === 'transition').length}
Total Tokens: ${currentNet.nodes.filter(n => n.type === 'place').reduce((sum, n) => sum + ((n as any).tokens || 0), 0)}` :
  `States: ${currentNet.nodes.filter(n => n.type === 'state').length}
Transitions: ${currentNet.edges.length}`}`;

    alert(info);
  }
</script>

<div class="bg-white border-b border-gray-200 shadow-sm">
  <div class="px-4 py-2">
    <div class="flex items-center space-x-6">
      <!-- File Menu -->
      <div class="relative group">
        <button class="px-3 py-1 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded transition-colors">
          File
        </button>
        <div class="absolute left-0 top-full mt-1 w-48 bg-white border border-gray-200 rounded-md shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50">
          <div class="py-1">
            <button
              on:click={() => createNewNet('pn')}
              class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
            >
              📄 New Petri Net
            </button>
            <button
              on:click={() => createNewNet('lts')}
              class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
            >
              📄 New Transition System
            </button>
            <div class="border-t border-gray-200 my-1"></div>
            <button
              on:click={importNet}
              class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
            >
              📁 Import APT
            </button>
            <button
              on:click={exportNet}
              class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
            >
              💾 Export APT
            </button>
            <div class="border-t border-gray-200 my-1"></div>
            <button
              on:click={handleRenameNet}
              class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
            >
              ✏️ Rename Net
            </button>
            <button
              on:click={handleDeleteNet}
              class="w-full text-left px-4 py-2 text-sm text-red-700 hover:bg-red-50 transition-colors"
            >
              🗑️ Delete Net
            </button>
          </div>
        </div>
      </div>

      <!-- Net Info -->
      <button
        on:click={showNetInfo}
        class="px-3 py-1 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded transition-colors"
      >
        Info
      </button>

      <!-- Net type indicator -->
      <div class="text-sm text-gray-500">
        <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
          {currentNet.type === 'pn' ? 'Petri Net' : 'Transition System'}
        </span>
      </div>

      <!-- Stats -->
      <div class="text-xs text-gray-500 flex items-center space-x-4">
        <span>{currentNet.nodes.length} nodes</span>
        <span>{currentNet.edges.length} edges</span>
        {#if currentNet.type === 'pn'}
          <span>{currentNet.nodes.filter(n => n.type === 'place').reduce((sum, n) => sum + ((n as any).tokens || 0), 0)} tokens</span>
        {/if}
      </div>
    </div>
  </div>
</div>

<style>
  .group:hover .group-hover\:opacity-100 {
    opacity: 1;
  }
  
  .group:hover .group-hover\:visible {
    visibility: visible;
  }
</style>