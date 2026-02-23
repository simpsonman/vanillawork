<template>
  <div class="min-h-screen bg-background text-foreground">
    <!-- Top Bar -->
    <LayoutAppTopBar />

    <div class="flex">
      <!-- Side Navigation -->
      <LayoutAppSideNav />

      <!-- Main Content -->
      <main class="flex-1 p-6 lg:p-8">
        <slot />
      </main>
    </div>
  </div>
</template>
