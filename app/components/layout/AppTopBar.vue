<template>
  <header class="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
    <div class="flex h-14 items-center px-4 lg:px-6">
      <!-- Logo -->
      <NuxtLink to="/" class="mr-4 flex items-center gap-2 font-bold text-lg">
  <div class="flex h-16 items-center justify-between px-4 sm:px-6 w-full">
    <!-- Left: Brand / Company Switcher -->
    <div class="flex items-center gap-6">
      <NuxtLink to="/" class="flex items-center gap-2 group">
        <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-primary-foreground font-bold shadow-sm group-hover:bg-primary/90 transition-colors">
          V
        </div>
        <span class="text-xl font-bold tracking-tight text-foreground hidden sm:inline-block">vanillawork</span>
      </NuxtLink>

      <div class="h-6 w-px bg-border/60 mx-2 hidden sm:block"></div>

      <!-- Company Selector (Simulated Dropdown for now) -->
      <Button variant="ghost" class="hidden sm:flex items-center gap-2 text-sm font-medium hover:bg-accent px-3 py-1.5 h-auto" @click="$router.push('/select-company')">
        <div class="h-5 w-5 rounded bg-primary/10 text-primary flex items-center justify-center text-xs font-bold">
          {{ currentCompany?.name?.charAt(0) || 'C' }}
        </div>
        {{ currentCompany?.name || '회사 선택' }}
        <svg class="w-4 h-4 text-muted-foreground ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
      </Button>
    </div>

    <!-- Right: User Profile & Actions -->
    <div class="flex items-center gap-3">
      <!-- Role Badge -->
      <div v-if="currentRole" class="hidden md:flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-secondary text-secondary-foreground border border-border/50">
        {{ currentRole }}
      </div>

      <!-- Notifications (Mock) -->
      <Button variant="ghost" size="icon" class="relative text-muted-foreground hover:text-foreground rounded-full w-9 h-9">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
        <span class="absolute top-2 right-2.5 w-2 h-2 rounded-full bg-destructive border-[1.5px] border-background"></span>
      </Button>

      <!-- User Profile -->
      <DropdownMenu>
        <DropdownMenuTrigger as-child>
          <Button variant="ghost" class="relative h-9 w-9 rounded-full">
            <Avatar class="h-9 w-9 border border-border/50 shadow-sm transition-transform hover:scale-105 active:scale-95">
              <AvatarImage :src="user?.user_metadata?.avatar_url" :alt="user?.email" />
              <AvatarFallback class="bg-primary/5 text-primary">{{ user?.email?.charAt(0).toUpperCase() || 'U' }}</AvatarFallback>
            </Avatar>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent class="w-56" align="end">
          <DropdownMenuLabel class="font-normal">
            <div class="flex flex-col space-y-1">
              <p class="text-sm font-medium leading-none">{{ user?.user_metadata?.full_name || '사용자' }}</p>
              <p class="text-xs leading-none text-muted-foreground">{{ user?.email }}</p>
            </div>
          </DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuGroup>
            <DropdownMenuItem @click="$router.push(`/app/${currentCompany?.id}/me/records`)">
              내 기록 보기
            </DropdownMenuItem>
            <DropdownMenuItem @click="$router.push('/select-company')">
              다른 회사로 전환
            </DropdownMenuItem>
          </DropdownMenuGroup>
          <DropdownMenuSeparator />
          <DropdownMenuItem @click="logout" class="text-destructive focus:bg-destructive focus:text-destructive-foreground">
            로그아웃
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const { user, logout } = useAuth()
const companyStore = useCompanyStore()

const currentCompany = computed(() => companyStore.currentCompany)
const currentRole = computed(() => companyStore.currentMembership?.role)
</script>
