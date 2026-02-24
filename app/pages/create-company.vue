<template>
  <div class="w-full max-w-lg space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
    <div class="text-center space-y-2">
      <h1 class="font-heading text-4xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
        새 워크스페이스
      </h1>
      <p class="text-[15px] text-slate-500 dark:text-slate-400">
        팀을 위한 새로운 워크스페이스를 만드세요
      </p>
    </div>

    <Card class="w-full relative overflow-hidden bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl border border-white/40 dark:border-slate-800/50 shadow-[0_8px_40px_-12px_rgba(0,0,0,0.1)] dark:shadow-[0_8px_40px_-12px_rgba(0,0,0,0.5)]">
      <!-- Subtle inner highlight -->
      <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/10 to-transparent"></div>
      
      <div class="relative z-10 px-8 py-8 space-y-6">
        <div class="space-y-4">
          <div class="space-y-2">
            <label for="companyName" class="text-sm font-medium text-slate-700 dark:text-slate-300">
              회사 또는 워크스페이스 이름
            </label>
            <input
              id="companyName"
              v-model="name"
              type="text"
              class="w-full h-12 px-4 rounded-lg bg-white/60 dark:bg-slate-900/60 border border-slate-200 dark:border-slate-700/50 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all shadow-sm placeholder:text-slate-400"
              placeholder="예: VanillaWork 코리아"
              :disabled="loading"
              @keyup.enter="handleCreate"
            />
          </div>
          
          <div class="space-y-2">
            <label for="timezone" class="text-sm font-medium text-slate-700 dark:text-slate-300">
              기본 타임존
            </label>
            <select
              id="timezone"
              v-model="timezone"
              class="w-full h-12 px-4 rounded-lg bg-white/60 dark:bg-slate-900/60 border border-slate-200 dark:border-slate-700/50 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all shadow-sm appearance-none"
              :disabled="loading"
            >
              <option value="Asia/Seoul">Asia/Seoul (한국 표준시)</option>
              <option value="America/New_York">America/New_York (동부 표준시)</option>
              <option value="Europe/London">Europe/London (그리니치 표준시)</option>
              <!-- 필요한 타임존 추가 가능 -->
            </select>
          </div>
        </div>

        <div class="pt-2 flex gap-3">
          <Button
            variant="outline"
            class="flex-1 h-12 bg-white/50 dark:bg-slate-800/50 hover:bg-white dark:hover:bg-slate-800 border-slate-200 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 transition-all"
            @click="$router.push('/select-company')"
            :disabled="loading"
          >
            취소
          </Button>
          <Button
            class="flex-[2] h-12 bg-indigo-600 hover:bg-indigo-700 text-white shadow-md transition-all duration-300 rounded-lg font-medium text-base relative overflow-hidden group"
            @click="handleCreate"
            :disabled="loading || !name.trim()"
          >
            <div class="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out"></div>
            <span class="relative flex items-center justify-center gap-2">
              <div v-if="loading" class="h-5 w-5 rounded-full border-[2.5px] border-white/30 border-t-white animate-spin"></div>
              <span>워크스페이스 만들기</span>
            </span>
          </Button>
        </div>
      </div>
    </Card>
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
const router = useRouter()

const name = ref('')
const timezone = ref('Asia/Seoul')
const loading = ref(false)

async function handleCreate() {
  if (!name.value.trim() || loading.value) return
  
  loading.value = true
  try {
    const { data: newCompany, error } = await companyStore.createCompany(name.value.trim(), timezone.value)
    if (error) {
      alert('회사 생성 중 오류가 발생했습니다: ' + error.message)
      return
    }
    
    // 회사 생성이 완료되면 해당 회사 대시보드로 즉시 이동
    if (newCompany) {
      await companyStore.selectCompany(newCompany.id)
      await router.push(`/app/${newCompany.id}/dashboard`)
    }
  } finally {
    loading.value = false
  }
}
</script>
