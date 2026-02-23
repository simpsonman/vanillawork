<template>
  <div class="min-h-screen bg-slate-50 dark:bg-background text-foreground transition-colors duration-300">
    <!-- Top Bar -->
    <header class="sticky top-0 z-40 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 shadow-sm">
      <div class="px-4 lg:px-8 max-w-[1600px] mx-auto">
        <LayoutAppTopBar />
      </div>
    </header>

    <div class="flex max-w-[1600px] mx-auto">
      <!-- Side Navigation -->
      <aside class="hidden md:block w-64 shrink-0 border-r border-border/40 min-h-[calc(100vh-4rem)] bg-card/30">
        <LayoutAppSideNav />
      </aside>

      <!-- Main Content -->
      <main class="flex-1 p-4 md:p-6 lg:p-8 animate-in fade-in slide-in-from-bottom-2 duration-500 relative">
        <div class="mx-auto w-full max-w-5xl">
          <slot />
        </div>
      </main>
    </div>
  </div>
</template>
