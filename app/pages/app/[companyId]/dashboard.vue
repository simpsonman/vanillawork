<template>
  <div class="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
    <!-- Header Section -->
    <div class="space-y-2">
      <h1 class="font-heading text-3xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
        대시보드
      </h1>
      <p class="text-[15px] text-slate-500 dark:text-slate-400">
        {{ company?.name }}에 오신 것을 환영합니다.
      </p>
    </div>

    <!-- Summary Cards -->
    <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
      <div v-for="card in summaryCards" :key="card.title" class="group relative overflow-hidden rounded-2xl bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl border border-white/60 dark:border-slate-800/50 shadow-[0_8px_30px_-12px_rgba(0,0,0,0.06)] dark:shadow-[0_8px_30px_-12px_rgba(0,0,0,0.3)] transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_12px_40px_-12px_rgba(0,0,0,0.1)] hover:bg-white/60 dark:hover:bg-slate-900/50 p-6 flex flex-col justify-between">
        <!-- Subtle inner highlight -->
        <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/10 to-transparent"></div>
        <!-- Decorative subtle glow -->
        <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/10 dark:bg-indigo-500/5 rounded-full blur-2xl group-hover:bg-indigo-500/20 transition-colors duration-500"></div>
        
        <div class="relative z-10 flex items-center justify-between">
          <div class="text-[13px] font-medium text-slate-500 dark:text-slate-400 tracking-wide">{{ card.title }}</div>
          <div class="p-2 rounded-lg bg-indigo-50 dark:bg-indigo-950/30 text-indigo-600 dark:text-indigo-400">
             <component :is="card.icon" class="w-4 h-4" />
          </div>
        </div>
        <div class="relative z-10 mt-4 flex items-baseline gap-2">
          <div class="text-3xl font-bold tracking-tight text-slate-800 dark:text-slate-100">{{ card.value }}</div>
          <div class="text-sm font-medium text-slate-500 dark:text-slate-400">{{ card.unit }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Calendar, Clock, FilePlus, Settings } from 'lucide-vue-next'

definePageMeta({
  middleware: ['auth', 'company'],
})

const { company } = useCompany()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// State for dashboard metrics
const remainingLeave = ref('--')
const workingDays = ref('--')
const pendingRequests = ref('--')
const overtimeHours = ref('--')

async function fetchDashboardMetrics() {
  if (!user.value?.id || !company?.value?.id) return

  try {
    const companyId = company.value.id
    const userId = user.value.id

    // 1. 잔여 연차 (합계: ACCRUAL, ADJUST 등 모두 포함)
    const { data: ledgerData } = await supabase
      .from('leave_ledger')
      .select('amount')
      .eq('company_id', companyId)
      .eq('user_id', userId)

    if (ledgerData && ledgerData.length > 0) {
      const sum = (ledgerData as any[]).reduce((acc, row) => acc + Number(row.amount || 0), 0)
      remainingLeave.value = sum.toString()
    } else {
      remainingLeave.value = '0'
    }

    // 2. 이번 달 근무일
    // 이번달의 정상 출근/조기퇴근 등 일수를 센다고 가정 
    // MVP이므로 임시로 근무 기록수 확인 (worked_minutes > 0)
    const startOfMonth = new Date()
    startOfMonth.setDate(1)
    
    const { count: workingDaysCount } = await supabase
      .from('attendance_daily')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', companyId)
      .eq('user_id', userId)
      .gte('date', startOfMonth.toISOString().split('T')[0])
      .gt('worked_minutes', 0)
    
    workingDays.value = workingDaysCount !== null ? workingDaysCount.toString() : '0'

    // 3. 대기 중 신청 건수
    const { count: pendingCount } = await supabase
      .from('leave_requests')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', companyId)
      .eq('user_id', userId)
      .eq('status', 'PENDING')
      
    pendingRequests.value = pendingCount !== null ? pendingCount.toString() : '0'

    // 4. 추가근무 (이번 달 승인된 OT 총 시간)
    const { data: otData } = await supabase
      .from('overtime_requests')
      .select('minutes')
      .eq('company_id', companyId)
      .eq('user_id', userId)
      .eq('status', 'APPROVED')
      .gte('start_at', startOfMonth.toISOString())
      
    if (otData && otData.length > 0) {
      const totalMinutes = (otData as any[]).reduce((acc, row) => acc + Number(row.minutes || 0), 0)
      overtimeHours.value = (Math.round((totalMinutes / 60) * 10) / 10).toString()
    } else {
      overtimeHours.value = '0'
    }
  } catch (error) {
    console.error('Failed to fetch dashboard metrics:', error)
  }
}

onMounted(() => {
  fetchDashboardMetrics()
})

const summaryCards = computed(() => [
  { title: '잔여 연차', value: remainingLeave.value, unit: '일', icon: Calendar },
  { title: '이번 달 근무일', value: workingDays.value, unit: '일', icon: Settings },
  { title: '대기 중 신청', value: pendingRequests.value, unit: '건', icon: FilePlus },
  { title: '추가근무', value: overtimeHours.value, unit: 'h', icon: Clock },
])
</script>
