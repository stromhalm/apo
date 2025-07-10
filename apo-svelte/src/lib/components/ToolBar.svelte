<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Net, ToolType } from '$lib/types.js';
  import { getToolsForNetType, TOOLS } from '$lib/tools.js';

  export let currentNet: Net;

  const dispatch = createEventDispatcher<{
    netUpdate: Net;
  }>();

  $: availableTools = getToolsForNetType(currentNet.type);

  function selectTool(toolType: ToolType) {
    const updatedNet = { ...currentNet, activeTool: toolType };
    dispatch('netUpdate', updatedNet);
  }
</script>

<div class="bg-white border-b border-gray-200 shadow-sm">
  <div class="px-4 py-2">
    <div class="flex items-center space-x-1">
      {#each availableTools as tool (tool.type)}
        <button
          on:click={() => selectTool(tool.type)}
          class="flex items-center justify-center w-10 h-10 rounded-md transition-colors
                 {currentNet.activeTool === tool.type 
                   ? 'bg-blue-100 text-blue-700 border-2 border-blue-300' 
                   : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100 border-2 border-transparent'}"
          title="{tool.name}: {tool.description}"
        >
          <span class="text-lg" role="img" aria-label={tool.name}>
            {tool.icon}
          </span>
        </button>
      {/each}
    </div>
  </div>
</div>