<script lang="ts">
  import { onMount } from 'svelte';
  import { writable } from 'svelte/store';
  import type { Net } from '$lib/types.js';
  import { loadNets, updateNet } from '$lib/storage.js';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import TopBar from '$lib/components/TopBar.svelte';
  import MenuBar from '$lib/components/MenuBar.svelte';
  import ToolBar from '$lib/components/ToolBar.svelte';
  import EditorCanvas from '$lib/components/EditorCanvas.svelte';

  // State management
  let nets: Net[] = [];
  let currentNet: Net | null = null;
  let sidebarOpen = true;

  // Load nets on component mount
  onMount(() => {
    nets = loadNets();
    if (nets.length > 0) {
      currentNet = nets[0];
    }
  });

  // Handle net updates
  function handleNetUpdate(updatedNet: Net) {
    if (!updatedNet) return;
    
    nets = nets.map(net => net.id === updatedNet.id ? updatedNet : net);
    currentNet = updatedNet;
    updateNet(nets, updatedNet);
  }

  // Handle net selection
  function handleNetSelect(net: Net) {
    currentNet = net;
  }

  // Handle nets update
  function handleNetsUpdate(updatedNets: Net[]) {
    nets = updatedNets;
    if (currentNet && !nets.find(n => n.id === currentNet!.id)) {
      currentNet = nets[0] || null;
    }
  }

  // Handle sidebar toggle
  function toggleSidebar() {
    sidebarOpen = !sidebarOpen;
  }
</script>

<div class="flex h-full w-full bg-gray-50">
  <!-- Sidebar -->
  <div class="relative {sidebarOpen ? 'w-80' : 'w-0'} transition-all duration-300 overflow-hidden">
    <Sidebar 
      {nets} 
      {currentNet} 
      on:select={(e) => handleNetSelect(e.detail)}
      on:update={(e) => handleNetsUpdate(e.detail)}
    />
  </div>

  <!-- Main content -->
  <div class="flex-1 flex flex-col min-w-0">
    <!-- Top bar -->
    <TopBar 
      {currentNet} 
      {sidebarOpen}
      on:toggleSidebar={toggleSidebar}
    />

    <!-- Menu bar -->
    {#if currentNet}
      <MenuBar 
        {nets}
        {currentNet} 
        on:netUpdate={(e) => handleNetUpdate(e.detail)}
        on:netsUpdate={(e) => handleNetsUpdate(e.detail)}
      />
    {/if}

    <!-- Tool bar -->
    {#if currentNet}
      <ToolBar 
        {currentNet} 
        on:netUpdate={(e) => handleNetUpdate(e.detail)}
      />
    {/if}

    <!-- Canvas -->
    <div class="flex-1 relative bg-white shadow-inner">
      {#if currentNet}
        <EditorCanvas 
          {currentNet} 
          on:netUpdate={(e) => handleNetUpdate(e.detail)}
        />
      {:else}
        <div class="flex items-center justify-center h-full text-gray-500">
          <div class="text-center">
            <h2 class="text-xl font-semibold mb-2">No nets available</h2>
            <p>Create a new net to get started</p>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>
