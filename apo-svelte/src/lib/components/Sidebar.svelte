<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Net, NetType } from '$lib/types.js';
  import { addNet, deleteNet, validateNetName } from '$lib/storage.js';
  import { createPetriNet, createTransitionSystem } from '$lib/nets.js';

  export let nets: Net[];
  export let currentNet: Net | null;

  const dispatch = createEventDispatcher<{
    select: Net;
    update: Net[];
  }>();

  // Form state
  let newNetName = '';
  let newNetType: NetType = 'pn';
  let showCreateForm = false;

  // Handle net selection
  function selectNet(net: Net) {
    dispatch('select', net);
  }

  // Handle net creation
  function createNewNet() {
    const validation = validateNetName(nets, newNetName);
    if (validation !== true) {
      alert(validation);
      return;
    }

    const newNet = newNetType === 'pn' 
      ? createPetriNet(newNetName)
      : createTransitionSystem(newNetName);
    
    const updatedNets = addNet(nets, newNet);
    dispatch('update', updatedNets);
    
    newNetName = '';
    showCreateForm = false;
    
    // Auto-select the new net
    dispatch('select', newNet);
  }

  // Handle net deletion
  function handleDeleteNet(net: Net) {
    if (confirm(`Do you really want to delete the net '${net.name}'?`)) {
      const updatedNets = deleteNet(nets, net.id);
      dispatch('update', updatedNets);
    }
  }

  // Cancel form
  function cancelForm() {
    newNetName = '';
    showCreateForm = false;
  }
</script>

<div class="h-full bg-white border-r border-gray-200 flex flex-col">
  <!-- Header -->
  <div class="p-4 border-b border-gray-200">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold text-gray-900">Your Nets</h2>
      <button
        on:click={() => showCreateForm = !showCreateForm}
        class="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
        title="Create new net"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
      </button>
    </div>
  </div>

  <!-- Create form -->
  {#if showCreateForm}
    <div class="p-4 bg-gray-50 border-b border-gray-200">
      <div class="space-y-3">
        <div>
          <label for="net-name" class="block text-sm font-medium text-gray-700 mb-1">
            Name
          </label>
          <input
            id="net-name"
            type="text"
            bind:value={newNetName}
            placeholder="Enter net name"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        
        <div>
          <label for="net-type" class="block text-sm font-medium text-gray-700 mb-1">
            Type
          </label>
          <select
            id="net-type"
            bind:value={newNetType}
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="pn">Petri Net</option>
            <option value="lts">Transition System</option>
          </select>
        </div>
        
        <div class="flex gap-2">
          <button
            on:click={createNewNet}
            disabled={!newNetName.trim()}
            class="flex-1 bg-blue-600 text-white px-3 py-2 rounded-md hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
          >
            Create
          </button>
          <button
            on:click={cancelForm}
            class="flex-1 bg-gray-200 text-gray-700 px-3 py-2 rounded-md hover:bg-gray-300 transition-colors"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  {/if}

  <!-- Nets list -->
  <div class="flex-1 overflow-y-auto">
    {#if nets.length === 0}
      <div class="p-4 text-center text-gray-500">
        <p>No nets available</p>
        <p class="text-sm">Create your first net to get started</p>
      </div>
    {:else}
      <div class="divide-y divide-gray-200">
        {#each nets as net (net.id)}
          <div 
            class="p-4 hover:bg-gray-50 cursor-pointer transition-colors {currentNet?.id === net.id ? 'bg-blue-50 border-r-2 border-blue-500' : ''}"
            on:click={() => selectNet(net)}
            on:keydown={(e) => e.key === 'Enter' && selectNet(net)}
            role="button"
            tabindex="0"
          >
            <div class="flex items-center justify-between">
              <div class="flex-1 min-w-0">
                <h3 class="text-sm font-medium text-gray-900 truncate">
                  {net.name}
                </h3>
                <p class="text-xs text-gray-500 mt-1">
                  {net.type === 'pn' ? 'Petri Net' : 'Transition System'}
                </p>
                <p class="text-xs text-gray-400 mt-1">
                  {net.nodes.length} nodes, {net.edges.length} edges
                </p>
              </div>
              
              <button
                on:click|stopPropagation={() => handleDeleteNet(net)}
                class="p-1 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
                title="Delete net"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
  
  <!-- Footer -->
  <div class="p-4 border-t border-gray-200 bg-gray-50">
    <div class="text-center">
      <div class="flex items-center justify-center mb-2">
        <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
          <span class="text-white font-bold text-sm">A</span>
        </div>
        <span class="ml-2 text-sm font-medium text-gray-900">APO</span>
      </div>
      <p class="text-xs text-gray-500">Online Petri Net Editor</p>
    </div>
  </div>
</div>