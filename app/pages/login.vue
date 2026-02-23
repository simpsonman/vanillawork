<template>
  <div class="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-background">
    <!-- Animated modern background elements -->
    <div class="absolute inset-0 bg-grid-slate-900/[0.04] bg-[bottom_1px_center] dark:bg-grid-slate-400/[0.05] dark:bg-bottom"></div>
    <div class="absolute left-1/2 top-0 -translate-x-1/2 blur-3xl xl:-top-6 w-[1200px] h-[400px] opacity-30 select-none pointer-events-none">
      <div class="absolute inset-0 bg-gradient-to-tr from-primary/30 to-indigo-500/20 [mask-image:linear-gradient(to_bottom,white,transparent)]"></div>
    </div>

    <!-- Main Content -->
    <div class="relative z-10 w-full max-w-sm px-4">
      <div class="text-center mb-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
        <h1 class="text-4xl font-extrabold tracking-tight text-foreground sm:text-5xl">
          vanillawork
        </h1>
        <p class="mt-3 text-sm text-muted-foreground/80 font-medium tracking-wide upercase">
          근태 · 연차 · 추가근무 관리
        </p>
      </div>

      <!-- Login Card -->
      <Card class="border-border/50 shadow-2xl backdrop-blur-sm bg-card/60 animate-in fade-in slide-in-from-bottom-8 duration-1000 delay-150">
        <CardHeader class="space-y-1 text-center">
          <CardTitle class="text-2xl font-bold tracking-tight">환영합니다</CardTitle>
          <CardDescription>
            사내 계정으로 안전하게 로그인하세요
          </CardDescription>
        </CardHeader>
        <CardContent class="grid gap-4">
          <Button
            variant="outline"
            class="w-full h-12 flex items-center justify-center gap-3 bg-background hover:bg-accent hover:text-accent-foreground transition-all duration-300 shadow-sm font-medium"
            @click="loading = true; loginWithGoogle()"
            :disabled="loading"
          >
            <!-- Google Logo SVG -->
            <svg v-if="!loading" class="h-5 w-5" viewBox="0 0 24 24">
              <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" />
              <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
              <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
              <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
            </svg>
            <div v-else class="h-5 w-5 rounded-full border-2 border-primary border-t-transparent animate-spin mr-2"></div>
            Google 계정으로 로그인
          </Button>
        </CardContent>
        <CardFooter class="flex flex-wrap items-center justify-center gap-2 text-xs text-muted-foreground">
          로그인 시 
          <a href="#" class="underline underline-offset-4 hover:text-primary transition-colors">이용약관</a> 및
          <a href="#" class="underline underline-offset-4 hover:text-primary transition-colors">개인정보처리방침</a>에 동의합니다.
        </CardFooter>
      </Card>
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
