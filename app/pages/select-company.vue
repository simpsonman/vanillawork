<template>
  <div class="relative flex min-h-screen flex-col items-center justify-center bg-background p-4 sm:p-8">
    <!-- Background styling -->
    <div class="absolute inset-0 bg-grid-slate-900/[0.04] bg-[bottom_1px_center] dark:bg-grid-slate-400/[0.05] dark:bg-bottom"></div>
    <div class="absolute right-0 top-0 -translate-y-12 translate-x-1/3 blur-3xl w-[800px] h-[400px] opacity-20 pointer-events-none">
      <div class="absolute inset-0 bg-gradient-to-bl from-primary/40 to-muted"></div>
    </div>

    <div class="relative z-10 w-full max-w-lg space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      
      <div class="text-center space-y-2">
        <h1 class="text-3xl font-bold tracking-tight text-foreground">
          회사 선택
        </h1>
        <p class="text-muted-foreground">
          접속할 워크스페이스를 선택해주세요
        </p>
      </div>

      <Card class="border-border/60 shadow-xl backdrop-blur-sm bg-card/80 overflow-hidden">
        <div v-if="loading" class="flex flex-col items-center justify-center p-12 space-y-4">
          <div class="h-8 w-8 rounded-full border-4 border-primary border-t-transparent animate-spin"></div>
          <p class="text-sm font-medium text-muted-foreground bg-clip-text text-transparent bg-gradient-to-r from-primary to-primary/60 animate-pulse">워크스페이스 정보를 불러오는 중...</p>
        </div>

        <div v-else-if="companies.length === 0" class="flex flex-col items-center p-10 text-center space-y-6">
          <div class="rounded-full bg-muted p-4">
            <svg class="w-8 h-8 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <div class="space-y-2">
            <h3 class="font-semibold text-lg text-foreground">소속된 회사가 없습니다</h3>
            <p class="text-sm text-muted-foreground max-w-[250px] mx-auto">새로운 회사를 생성하거나, 관리자에게 초대를 요청하세요.</p>
          </div>
          <Button class="w-full mt-4 h-11" @click="$router.push('/create-company')">
            새 회사 만들기
          </Button>
        </div>

        <div v-else class="p-2 space-y-1">
          <button
            v-for="company in companies"
            :key="company.id"
            class="group w-full flex items-center justify-between rounded-lg p-4 text-left transition-all hover:bg-accent/80 active:scale-[0.99] border border-transparent hover:border-border/50"
            @click="selectAndGo(company.id)"
          >
            <div class="flex items-center gap-4">
              <div class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 text-primary font-bold text-lg group-hover:scale-110 transition-transform duration-300">
                {{ company.name.substring(0, 1).toUpperCase() }}
              </div>
              <div>
                <div class="font-semibold text-foreground text-base">{{ company.name }}</div>
                <div class="text-sm text-muted-foreground mt-0.5 flex items-center gap-1.5">
                  <span class="inline-block w-1.5 h-1.5 rounded-full bg-green-500"></span>
                  {{ company.timezone }}
                </div>
              </div>
            </div>
            
            <div class="text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity translate-x-2 group-hover:translate-x-0 duration-300">
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            </div>
          </button>
        </div>
      </Card>
      
      <!-- User info / Logout -->
      <div v-if="!loading" class="text-center pt-2">
        <button class="text-sm text-muted-foreground hover:text-foreground transition-colors underline underline-offset-4" @click="logout">
          다른 계정으로 로그인
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

definePageMeta({
  middleware: ['auth'],
  layout: false,
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
