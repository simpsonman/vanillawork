<template>
  <div class="relative flex min-h-screen flex-col bg-background/50 selection:bg-primary/30 text-foreground transition-colors duration-300 overflow-hidden">
    <!-- Dynamic Mesh Gradient Background & Ambient Orbs -->
    <div class="fixed inset-0 z-0 overflow-hidden pointer-events-none w-full h-full bg-background">
      <!-- Base Gradient layered with noise for texture -->
      <div class="absolute inset-0 bg-gradient-to-br from-indigo-50/40 via-white to-purple-50/40 dark:from-slate-950 dark:via-blue-950/20 dark:to-slate-900 opacity-80" />
      
      <!-- Moving Orbs -->
      <div class="absolute top-[-10%] left-[-10%] w-[50vw] h-[50vw] rounded-full bg-indigo-500/20 dark:bg-indigo-600/20 blur-[120px] mix-blend-multiply dark:mix-blend-screen animate-blob" />
      <div class="absolute top-[20%] right-[-10%] w-[40vw] h-[40vw] rounded-full bg-purple-500/20 dark:bg-fuchsia-600/20 blur-[120px] mix-blend-multiply dark:mix-blend-screen animate-blob animation-delay-2000" />
      <div class="absolute bottom-[-20%] left-[20%] w-[60vw] h-[60vw] rounded-full bg-blue-500/20 dark:bg-cyan-600/20 blur-[120px] mix-blend-multiply dark:mix-blend-screen animate-blob animation-delay-4000" />
      
      <!-- Subtle Grid Overlay -->
      <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCI+PHBhdGggZD0iTTAgMGg0MHY0MEgwVjB6bTIwIDIwaDIwdjIwSDIwdjIwek0waDIwaDIwaDIweiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJyZ2JhKDI1NSwyNTUsMjU1LDAuMDUpIi8+PC9zdmc+')] dark:bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCI+PHBhdGggZD0iTTAgMGg0MHY0MEgwVjB6bTIwIDIwaDIwdjIwSDIwdjIwek0waDIwaDIwaDIweiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJyZ2JhKDAsMCwwLDAuMDUpIi8+PC9zdmc+')] bg-repeat opacity-20 dark:opacity-40" mask="linear-gradient(to bottom, white, transparent)"></div>
    </div>

    <!-- Top Bar -->
    <header class="relative z-40 w-full border-b border-white/60 dark:border-slate-800/50 bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl shadow-sm">
      <div class="px-4 lg:px-8 max-w-[1600px] mx-auto">
        <LayoutAppTopBar />
      </div>
    </header>

    <div class="relative z-10 flex max-w-[1600px] mx-auto w-full flex-1">
      <!-- Side Navigation -->
      <aside class="hidden md:block w-64 shrink-0 border-r border-white/60 dark:border-slate-800/50 min-h-[calc(100vh-4rem)] bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl">
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

<style scoped>
@keyframes blob {
  0% { transform: translate(0px, 0px) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0px, 0px) scale(1); }
}

.animate-blob {
  animation: blob 15s infinite alternate cubic-bezier(0.4, 0, 0.2, 1);
}

.animation-delay-2000 {
  animation-delay: 2s;
}

.animation-delay-4000 {
  animation-delay: 4s;
}
</style>
