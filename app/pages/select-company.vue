<template>
  <div class="w-full max-w-lg space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
    
    <div class="text-center space-y-2">
      <h1 class="font-heading text-4xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
        회사 선택
      </h1>
      <p class="text-[15px] text-slate-500 dark:text-slate-400">
        접속할 워크스페이스를 선택해주세요
      </p>
    </div>

    <Card class="w-full relative overflow-hidden bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl border border-white/40 dark:border-slate-800/50 shadow-[0_8px_40px_-12px_rgba(0,0,0,0.1)] dark:shadow-[0_8px_40px_-12px_rgba(0,0,0,0.5)]">
      <!-- Subtle inner highlight -->
      <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/10 to-transparent"></div>
      
      <div class="relative z-10">
        <div v-if="loading" class="flex flex-col items-center justify-center p-12 space-y-4">
          <div class="h-8 w-8 rounded-full border-4 border-indigo-500 border-t-transparent animate-spin"></div>
          <p class="text-sm font-medium text-indigo-600/80 dark:text-indigo-400/80 animate-pulse">워크스페이스 정보를 불러오는 중...</p>
        </div>

        <div v-else-if="companies.length === 0" class="flex flex-col items-center p-10 text-center space-y-6">
          <div class="rounded-full bg-white/50 dark:bg-slate-800/50 p-4 border border-white/20 dark:border-slate-700/50 shadow-sm">
            <svg class="w-8 h-8 text-slate-400 dark:text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <div class="space-y-2">
            <h3 class="font-semibold text-lg text-slate-800 dark:text-slate-200">소속된 회사가 없습니다</h3>
            <p class="text-[14px] text-slate-500 dark:text-slate-400 max-w-[250px] mx-auto">새로운 회사를 생성하거나, 관리자에게 초대를 요청하세요.</p>
          </div>
          <Button class="w-full mt-4 h-12 bg-indigo-600 hover:bg-indigo-700 text-white shadow-md transition-all duration-300 rounded-lg font-medium text-base" @click="$router.push('/create-company')">
            새 회사 만들기
          </Button>
        </div>

        <div v-else class="p-3 space-y-2">
          <button
            v-for="company in companies"
            :key="company.id"
            class="group w-full flex items-center justify-between rounded-xl p-4 text-left transition-all duration-300 hover:bg-white/60 dark:hover:bg-slate-800/60 active:scale-[0.98] border border-transparent hover:border-white/50 dark:hover:border-slate-700/50 shadow-sm hover:shadow-md"
            @click="selectAndGo(company.id)"
          >
            <div class="flex items-center gap-4">
              <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-purple-500 text-white font-bold text-xl shadow-inner group-hover:scale-105 transition-transform duration-300">
                {{ company.name.substring(0, 1).toUpperCase() }}
              </div>
              <div>
                <div class="font-semibold text-slate-800 dark:text-slate-100 text-[16px]">{{ company.name }}</div>
                <div class="text-[13px] text-slate-500 dark:text-slate-400 mt-1 flex items-center gap-1.5">
                  <span class="inline-block w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]"></span>
                  {{ company.timezone }}
                </div>
              </div>
            </div>
            
            <div class="text-indigo-500/50 dark:text-indigo-400/50 opacity-0 group-hover:opacity-100 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-all translate-x-2 group-hover:translate-x-0 duration-300">
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            </div>
          </button>
        </div>
      </div>
    </Card>
    
    <!-- User info / Logout -->
    <div v-if="!loading" class="text-center pt-2">
      <button class="text-[14px] text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-200 transition-colors underline underline-offset-4 font-medium" @click="logout">
        다른 계정으로 로그인 (로그아웃)
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

definePageMeta({
  middleware: ['auth'],
  layout: 'auth',
})

const companyStore = useCompanyStore()
const { logout } = useAuth()
const router = useRouter()

const companies = computed(() => companyStore.companies)
const loading = computed(() => companyStore.loading)

onMounted(async () => {
  await companyStore.fetchCompanies()
  // 회사가 1개면 자동 이동
  if (companies.value.length === 1) {
    await selectAndGo(companies.value[0].id)
  }
})

async function selectAndGo(companyId: string) {
  await companyStore.selectCompany(companyId)
  await router.push(`/app/${companyId}/dashboard`)
}
</script>
