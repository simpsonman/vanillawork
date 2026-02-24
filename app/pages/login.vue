<template>
  <div class="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-background/50 selection:bg-primary/30">
    
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

    <!-- Main Content Container -->
    <div class="relative z-10 w-full max-w-md px-6 py-12 flex flex-col items-center">
      
      <!-- Brand & Welcome Section -->
      <div class="text-center mb-10 space-y-3 animate-in fade-in slide-in-from-bottom-8 duration-1000">
        <div class="mx-auto w-16 h-16 bg-white/10 dark:bg-black/20 backdrop-blur-md rounded-2xl border border-white/20 dark:border-white/10 shadow-lg flex items-center justify-center mb-6">
          <svg class="w-8 h-8 text-indigo-600 dark:text-indigo-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
        </div>
        <h1 class="font-heading text-5xl font-black tracking-tighter text-slate-900 dark:text-white mb-2 drop-shadow-sm">
          vanillawork
        </h1>
        <p class="text-[14px] uppercase tracking-[0.2em] font-medium text-indigo-600/80 dark:text-indigo-400/80">
          근태 · 연차 · 추가근무
        </p>
      </div>

      <!-- Glassmorphic Login Card -->
      <Card class="w-full relative overflow-hidden bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl border border-white/40 dark:border-slate-800/50 shadow-[0_8px_40px_-12px_rgba(0,0,0,0.1)] dark:shadow-[0_8px_40px_-12px_rgba(0,0,0,0.5)] animate-in fade-in zoom-in-95 duration-1000 delay-150">
        <!-- Subtle inner highlight -->
        <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/10 to-transparent"></div>
        
        <CardHeader class="pt-8 pb-6 space-y-2 text-center relative z-10">
          <CardTitle class="font-heading text-2xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
            반갑습니다 👋
          </CardTitle>
          <CardDescription class="text-slate-500 dark:text-slate-400 text-[15px]">
            사내 구글 계정으로 로그인 또는 회원가입을 
            <br />
            진행해주세요
          </CardDescription>
        </CardHeader>
        
        <CardContent class="grid gap-6 px-8 relative z-10 pb-8">
          <div class="relative group">
            <div class="absolute -inset-0.5 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-lg blur opacity-0 group-hover:opacity-20 transition duration-500 group-hover:duration-200"></div>
            <Button
              variant="outline"
              class="relative w-full h-14 flex items-center justify-center gap-4 bg-white dark:bg-slate-900/80 hover:bg-slate-50 dark:hover:bg-slate-800/80 border-slate-200 dark:border-slate-700/50 shadow-sm transition-all duration-300 rounded-lg text-slate-700 dark:text-slate-200 font-medium text-base group-hover:-translate-y-[1px]"
              @click="loading = true; loginWithGoogle()"
              :disabled="loading"
            >
              <svg v-if="!loading" class="h-5 w-5 transition-transform duration-300 group-hover:scale-110" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" />
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
              </svg>
              <div v-else class="h-5 w-5 rounded-full border-[2.5px] border-indigo-500 border-t-transparent animate-spin mr-1"></div>
              <span>Google 계정으로 계속하기</span>
            </Button>
          </div>
        </CardContent>
        
        <CardFooter class="px-8 pb-8 pt-0 flex flex-col items-center justify-center gap-2 text-[13px] text-slate-500 dark:text-slate-400 relative z-10">
          <p>
            로그인 시 당사의
            <a href="#" class="font-medium text-slate-700 dark:text-slate-300 underline underline-offset-4 decoration-slate-300 dark:decoration-slate-600 hover:text-indigo-600 dark:hover:text-indigo-400 hover:decoration-indigo-600/50 dark:hover:decoration-indigo-400/50 transition-all">이용약관</a> 
            및 
            <a href="#" class="font-medium text-slate-700 dark:text-slate-300 underline underline-offset-4 decoration-slate-300 dark:decoration-slate-600 hover:text-indigo-600 dark:hover:text-indigo-400 hover:decoration-indigo-600/50 dark:hover:decoration-indigo-400/50 transition-all">개인정보처리방침</a>에
          </p>
          <p>동의하는 것으로 간주합니다.</p>
        </CardFooter>
      </Card>
      
      <!-- Footer Note -->
      <div class="mt-8 text-center animate-in fade-in duration-1000 delay-500 opacity-60 hover:opacity-100 transition-opacity">
        <p class="text-xs text-slate-500 dark:text-slate-400 font-medium">
          &copy; {{ new Date().getFullYear() }} VanillaWork. All rights reserved.
        </p>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

definePageMeta({
  layout: false,
})

const { loginWithGoogle } = useAuth()
const loading = ref(false)
</script>

<style scoped>
@keyframes blob {
  0% { transform: translate(0px, 0px) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0px, 0px) scale(1); }
}

.animate-blob {
  animation: blob 10s infinite alternate cubic-bezier(0.4, 0, 0.2, 1);
}

.animation-delay-2000 {
  animation-delay: 2s;
}

.animation-delay-4000 {
  animation-delay: 4s;
}
</style>
