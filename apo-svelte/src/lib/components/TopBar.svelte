<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Net } from '$lib/types.js';

  export let currentNet: Net | null;
  export let sidebarOpen: boolean;

  const dispatch = createEventDispatcher<{
    toggleSidebar: void;
  }>();

  function handleToggleSidebar() {
    dispatch('toggleSidebar');
  }

  function showAbout() {
    alert(`APO - Online Petri Net Editor

A modern web interface for creating and analyzing Petri nets and transition systems.

Features:
• Interactive editor with physics simulation
• Support for Petri Nets and Labeled Transition Systems
• Local browser storage
• APT format import/export
• Modern responsive design

Built with SvelteKit and TypeScript.`);
  }
</script>

<div class="bg-white border-b border-gray-200 shadow-sm">
  <div class="flex items-center justify-between px-4 py-3">
    <div class="flex items-center space-x-3">
      <!-- Sidebar toggle button -->
      <button
        on:click={handleToggleSidebar}
        class="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors md:hidden"
        title="Toggle sidebar"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      <!-- Logo and title -->
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 bg-gradient-to-br from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
          <span class="text-white font-bold text-sm">A</span>
        </div>
        <div>
          <h1 class="text-lg font-semibold text-gray-900">
            {currentNet ? currentNet.name : 'APO'}
          </h1>
          {#if currentNet}
            <p class="text-xs text-gray-500">
              {currentNet.type === 'pn' ? 'Petri Net' : 'Transition System'}
            </p>
          {/if}
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div class="flex items-center space-x-2">
      <!-- Help/About button -->
      <button
        on:click={showAbout}
        class="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
        title="About APO"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </button>

      <!-- GitHub link -->
      <a
        href="https://github.com/stromhalm/apo"
        target="_blank"
        rel="noopener noreferrer"
        class="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
        title="View on GitHub"
      >
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
          <path d="M12 0C5.374 0 0 5.373 0 12 0 17.302 3.438 21.8 8.207 23.387c.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
        </svg>
      </a>

      <!-- Desktop sidebar toggle -->
      <button
        on:click={handleToggleSidebar}
        class="hidden md:flex p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
        title="{sidebarOpen ? 'Hide' : 'Show'} sidebar"
      >
        {#if sidebarOpen}
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
          </svg>
        {:else}
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
          </svg>
        {/if}
      </button>
    </div>
  </div>
</div>