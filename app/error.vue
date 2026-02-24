<template>
  <NuxtLayout name="auth">
    <div class="w-full max-w-lg space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      
      <div class="text-center space-y-4">
        <h1 class="font-heading text-8xl font-black tracking-tighter text-indigo-500 drop-shadow-md">
          {{ error?.statusCode }}
        </h1>
        <h2 class="text-2xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
          {{ error?.statusMessage || '웹 페이지를 찾을 수 없습니다' }}
        </h2>
        <p class="text-[15px] text-slate-500 dark:text-slate-400 max-w-md mx-auto">
          요청하신 페이지가 사라졌거나 잘못된 경로입니다. 
          <br />
          홈으로 돌아가 다시 시도해주세요.
        </p>
      </div>

      <Card class="w-full relative overflow-hidden bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl border border-white/40 dark:border-slate-800/50 shadow-[0_8px_40px_-12px_rgba(0,0,0,0.1)] dark:shadow-[0_8px_40px_-12px_rgba(0,0,0,0.5)]">
        <!-- Subtle inner highlight -->
        <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/10 to-transparent"></div>
        
        <div class="relative z-10 px-8 py-8 flex flex-col items-center gap-6">
          <div class="rounded-2xl bg-indigo-500/10 dark:bg-indigo-500/20 p-4 shrink-0">
            <svg class="w-10 h-10 text-indigo-600 dark:text-indigo-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          
          <Button class="w-full h-12 bg-slate-900 hover:bg-slate-800 dark:bg-slate-100 dark:hover:bg-white dark:text-slate-900 text-white shadow-md transition-all duration-300 rounded-lg font-medium text-base group" @click="handleError">
            <span class="flex items-center justify-center gap-2">
              <svg class="w-5 h-5 group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
              홈으로 돌아가기
            </span>
          </Button>
        </div>
      </Card>
      
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

const props = defineProps({
  error: Object
})

const handleError = () => clearError({ redirect: '/select-company' })
</script>
